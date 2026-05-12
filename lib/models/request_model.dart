import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  open,
  negotiation,
  waitingConfirmation,
  accepted,
  purchased,
  completed,
}

extension RequestStatusX on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.open:
        return 'OPEN';
      case RequestStatus.negotiation:
        return 'NEGOTIATION';
      case RequestStatus.waitingConfirmation:
        return 'WAITING_CONFIRMATION';
      case RequestStatus.accepted:
        return 'ACCEPTED';
      case RequestStatus.purchased:
        return 'PURCHASED';
      case RequestStatus.completed:
        return 'COMPLETED';
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.negotiation:
        return 'Negosiasi';
      case RequestStatus.waitingConfirmation:
        return 'Menunggu Konfirmasi';
      case RequestStatus.accepted:
        return 'Diterima';
      case RequestStatus.purchased:
        return 'Dibeli';
      case RequestStatus.completed:
        return 'Selesai';
    }
  }

  static RequestStatus fromString(String? value) {
    return RequestStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RequestStatus.open,
    );
  }
}

class RequestModel {
  final String id;
  final String requesterId;
  final String requesterName;
  final String itemName;
  final String location;
  final num estimatedPrice;
  final num initialFee;
  final num currentFee;
  final String? note;
  final RequestStatus status;
  final String? travelerId;
  final String? travelerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  RequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.itemName,
    required this.location,
    required this.estimatedPrice,
    required this.initialFee,
    required this.currentFee,
    this.note,
    required this.status,
    this.travelerId,
    this.travelerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return RequestModel(
      id: doc.id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      itemName: map['itemName'] ?? '',
      location: map['location'] ?? '',
      estimatedPrice: (map['estimatedPrice'] ?? 0) as num,
      initialFee: (map['initialFee'] ?? 0) as num,
      currentFee: (map['currentFee'] ?? 0) as num,
      note: map['note'],
      status: RequestStatusX.fromString(map['status']),
      travelerId: map['travelerId'],
      travelerName: map['travelerName'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'requesterId': requesterId,
        'requesterName': requesterName,
        'itemName': itemName,
        'location': location,
        'estimatedPrice': estimatedPrice,
        'initialFee': initialFee,
        'currentFee': currentFee,
        'note': note,
        'status': status.value,
        'travelerId': travelerId,
        'travelerName': travelerName,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
