import 'user.dart';

class Contribution {
  final String? id;
  final dynamic member; // Can be String (ID) or User object
  final double amount;
  final String type;
  final DateTime date;
  final String status;
  final DateTime? createdAt;

  Contribution({
    this.id,
    required this.member,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
    this.createdAt,
  });

  /// Returns the member's ID as a String, whether member is a User or a raw ID string
  String? get memberId {
    if (member is User) return (member as User).id;
    if (member is String) return member as String;
    return null;
  }

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['_id'],
      member: json['member'] is Map<String, dynamic> 
          ? User.fromJson(json['member']) 
          : json['member'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'Cotisation',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'Payé',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member': member is User ? (member as User).id : member,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
