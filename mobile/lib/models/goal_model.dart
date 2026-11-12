import 'deposit_model.dart';

class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.dueDate,
    required this.status,
    required this.deposits,
  });

  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime dueDate;
  final String status;
  final List<DepositModel> deposits;

  bool get isCompleted => status == 'CONCLUIDA';

  double get progress =>
      (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final rawDeposits = json['deposits'] as List<dynamic>? ?? const [];
    return GoalModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      deposits: rawDeposits
          .map(
            (deposit) => DepositModel.fromJson(
              deposit as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }
}
