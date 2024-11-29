// lib/models/reservation.dart

class Reservation {
  final int id;
  final int userId;
  final int flowerId;
  final int quantity;
  final String partyName;
  final String sellDate;
  final String status;
  final int? processedBy;
  final String? processedByName;
  final String flowerName;

  Reservation({
    required this.id,
    required this.userId,
    required this.flowerId,
    required this.quantity,
    required this.partyName,
    required this.sellDate,
    required this.status,
    this.processedBy,
    this.processedByName,
    required this.flowerName,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      flowerId: json['flower_id'],
      quantity: json['quantity'],
      partyName: json['party_name'],
      sellDate: json['sell_date'],
      status: json['status'],
      processedBy: json['processed_by'],
      processedByName: json['processed_by_name'],
      flowerName: json['flower_name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'flower_id': flowerId,
      'quantity': quantity,
      'party_name': partyName,
      'sell_date': sellDate,
      'status': status,
      'processed_by': processedBy,
      'processed_by_name': processedByName,
      'flower_name': flowerName,
    };
  }
}
