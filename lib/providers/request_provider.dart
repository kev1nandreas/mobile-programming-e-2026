import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../services/request_service.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _service = RequestService();

  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  Stream<List<RequestModel>> openRequests() => _service.openRequestsStream();
  Stream<List<RequestModel>> myRequests(String uid) =>
      _service.myRequestsStream(uid);
  Stream<List<RequestModel>> myJastips(String uid) =>
      _service.myJastipsStream(uid);
  Stream<RequestModel?> requestStream(String id) =>
      _service.requestStream(id);
  Stream<List<MessageModel>> messages(String id) =>
      _service.messagesStream(id);

  Future<String?> createRequest({
    required UserModel requester,
    required String itemName,
    required String location,
    required num estimatedPrice,
    required num fee,
    String? note,
  }) async {
    return _wrap(() async {
      final now = DateTime.now();
      final request = RequestModel(
        id: '',
        requesterId: requester.uid,
        requesterName: requester.name,
        itemName: itemName,
        location: location,
        estimatedPrice: estimatedPrice,
        initialFee: fee,
        currentFee: fee,
        note: note,
        status: RequestStatus.open,
        createdAt: now,
        updatedAt: now,
      );
      return _service.createRequest(request);
    });
  }

  Future<void> takeRequest({
    required String requestId,
    required UserModel traveler,
  }) {
    return _wrap(() => _service.takeRequest(
          requestId: requestId,
          travelerId: traveler.uid,
          travelerName: traveler.name,
        ));
  }

  Future<void> proposeFee(String requestId, num newFee) =>
      _wrap(() => _service.proposeFee(requestId: requestId, newFee: newFee));

  Future<void> acceptFee(String id) => _wrap(() => _service.acceptFee(id));
  Future<void> rejectFee(String id) => _wrap(() => _service.rejectFee(id));
  Future<void> confirmAccept(String id) =>
      _wrap(() => _service.confirmAccept(id));
  Future<void> markPurchased(String id) =>
      _wrap(() => _service.markPurchased(id));
  Future<void> completeOrder(String id) =>
      _wrap(() => _service.completeOrder(id));
  Future<void> deleteRequest(String id) =>
      _wrap(() => _service.deleteRequest(id));

  Future<void> sendMessage({
    required String requestId,
    required UserModel sender,
    required String text,
  }) {
    final msg = MessageModel(
      id: '',
      senderId: sender.uid,
      senderName: sender.name,
      text: text,
      createdAt: DateTime.now(),
    );
    return _service.sendMessage(requestId, msg);
  }

  Future<T> _wrap<T>(Future<T> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final result = await action();
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
