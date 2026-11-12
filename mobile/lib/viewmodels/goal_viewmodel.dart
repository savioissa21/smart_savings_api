import 'package:flutter/foundation.dart';

import '../models/goal_model.dart';
import '../services/goal_api.dart';

class GoalViewModel extends ChangeNotifier {
  GoalViewModel({GoalApi? api}) : _api = api ?? GoalApiService();

  final GoalApi _api;
  List<GoalModel> _goals = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<GoalModel> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    if (_api is GoalApiService) _api.close();
    super.dispose();
  }

  List<GoalModel> get activeGoals =>
      _goals.where((goal) => !goal.isCompleted).toList(growable: false);

  List<GoalModel> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList(growable: false);

  double get totalSaved =>
      _goals.fold(0, (total, goal) => total + goal.currentAmount);

  Future<void> loadGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _goals = await _api.fetchGoals();
    } catch (error) {
      _errorMessage = _messageFor(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal({
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  }) {
    return _runMutation(
      () => _api.createGoal(
        title: title,
        targetAmount: targetAmount,
        dueDate: dueDate,
      ),
    );
  }

  Future<bool> updateGoal({
    required int goalId,
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  }) {
    return _runMutation(
      () => _api.updateGoal(
        goalId: goalId,
        title: title,
        targetAmount: targetAmount,
        dueDate: dueDate,
      ),
    );
  }

  Future<bool> addDeposit({
    required int goalId,
    required double amount,
    required DateTime date,
  }) {
    return _runMutation(
      () => _api.addDeposit(goalId: goalId, amount: amount, date: date),
    );
  }

  Future<bool> deleteGoal(int goalId) {
    return _runMutation(() => _api.deleteGoal(goalId));
  }

  Future<bool> _runMutation(Future<void> Function() operation) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
      _goals = await _api.fetchGoals();
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is GoalApiException) return error.message;
    if (error is FormatException) return error.message;
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
