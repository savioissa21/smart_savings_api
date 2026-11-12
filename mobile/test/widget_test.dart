import 'package:flutter_test/flutter_test.dart';
import 'package:smart_savings/models/goal_model.dart';

void main() {
  test('GoalModel maps API JSON and bounds progress to 100 percent', () {
    final goal = GoalModel.fromJson({
      'id': 7,
      'title': 'Viagem',
      'targetAmount': 1000,
      'currentAmount': 1200,
      'dueDate': '2027-05-10',
      'status': 'CONCLUIDA',
      'deposits': [
        {'id': 3, 'amount': 1200, 'date': '2026-11-12'},
      ],
    });

    expect(goal.id, 7);
    expect(goal.isCompleted, isTrue);
    expect(goal.progress, 1);
    expect(goal.deposits.single.amount, 1200);
    expect(goal.dueDate, DateTime(2027, 5, 10));
  });
}
