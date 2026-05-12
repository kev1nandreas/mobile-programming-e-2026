import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('requests');

  // CREATE
  Future<String> createRequest(RequestModel request) async {
    final doc = await _requests.add(request.toMap());
    return doc.id;
  }

  // READ - stream all OPEN requests (untuk Home)
  Stream<List<RequestModel>> openRequestsStream() {
    return _requests
        .where('status', isEqualTo: RequestStatus.open.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RequestModel.fromDoc).toList());
  }

  // READ - stream request milik user (sebagai requester)
  // Tidak pakai orderBy agar tidak butuh composite index di Firestore.
  // Sorting dilakukan di client.
  Stream<List<RequestModel>> myRequestsStream(String uid) {
    return _requests
        .where('requesterId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(RequestModel.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // READ - stream request yang user ambil sebagai traveler
  Stream<List<RequestModel>> myJastipsStream(String uid) {
    return _requests
        .where('travelerId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(RequestModel.fromDoc).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  // READ - single request stream (detail)
  Stream<RequestModel?> requestStream(String id) {
    return _requests.doc(id).snapshots().map(
          (doc) => doc.exists ? RequestModel.fromDoc(doc) : null,
        );
  }

  // UPDATE - traveler menerima request -> ke negotiation/waiting
  Future<void> takeRequest({
    required String requestId,
    required String travelerId,
    required String travelerName,
  }) async {
    await _requests.doc(requestId).update({
      'travelerId': travelerId,
      'travelerName': travelerName,
      'status': RequestStatus.negotiation.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - traveler ajukan fee baru
  Future<void> proposeFee({
    required String requestId,
    required num newFee,
  }) async {
    await _requests.doc(requestId).update({
      'currentFee': newFee,
      'status': RequestStatus.negotiation.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - requester terima fee -> waiting confirmation
  Future<void> acceptFee(String requestId) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.waitingConfirmation.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - requester tolak fee -> kembali negosiasi
  Future<void> rejectFee(String requestId) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.negotiation.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - konfirmasi accept -> ACCEPTED (request terkunci)
  Future<void> confirmAccept(String requestId) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.accepted.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - traveler konfirmasi sudah beli -> PURCHASED
  Future<void> markPurchased(String requestId) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.purchased.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE - requester selesaikan pesanan -> COMPLETED
  Future<void> completeOrder(String requestId) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.completed.value,
      'updatedAt': Timestamp.now(),
    });
  }

  // DELETE - hanya saat masih OPEN
  Future<void> deleteRequest(String requestId) async {
    await _requests.doc(requestId).delete();
  }

  // ============ CHAT ============
  CollectionReference<Map<String, dynamic>> _messages(String requestId) =>
      _requests.doc(requestId).collection('messages');

  Stream<List<MessageModel>> messagesStream(String requestId) {
    return _messages(requestId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MessageModel.fromDoc).toList());
  }

  Future<void> sendMessage(String requestId, MessageModel message) async {
    await _messages(requestId).add(message.toMap());
  }
}
