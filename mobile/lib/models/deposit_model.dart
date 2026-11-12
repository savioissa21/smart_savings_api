class DepositModel {
  const DepositModel({
    required this.id,
    required this.amount,
    required this.date,
  });

  final int id;
  final double amount;
  final DateTime date;

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
