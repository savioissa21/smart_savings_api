import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/goal_model.dart';

abstract interface class GoalApi {
  Future<List<GoalModel>> fetchGoals();

  Future<void> createGoal({
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  });

  Future<void> updateGoal({
    required int goalId,
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  });

  Future<void> addDeposit({
    required int goalId,
    required double amount,
    required DateTime date,
  });

  Future<void> deleteGoal(int goalId);
}

class GoalApiException implements Exception {
  const GoalApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoalApiService implements GoalApi {
  GoalApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:8080/api',
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  void close() {
    _client.close();
  }

  Uri get _goalsUri => Uri.parse('$_baseUrl/goals');

  @override
  Future<List<GoalModel>> fetchGoals() async {
    final response = await _send(() => _client.get(_goalsUri));
    final body = _decodeBody(response);
    if (body is! List<dynamic>) {
      throw const FormatException('A resposta de metas tem formato inválido.');
    }

    return body
        .map(
          (goal) => GoalModel.fromJson(goal as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<void> createGoal({
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  }) async {
    final response = await _send(
      () => _client.post(
        _goalsUri,
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'targetAmount': targetAmount,
          'dueDate': _dateOnly(dueDate),
        }),
      ),
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> updateGoal({
    required int goalId,
    required String title,
    required double targetAmount,
    required DateTime dueDate,
  }) async {
    final response = await _send(
      () => _client.put(
        _goalsUri.resolve('./goals/$goalId'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'targetAmount': targetAmount,
          'dueDate': _dateOnly(dueDate),
        }),
      ),
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> addDeposit({
    required int goalId,
    required double amount,
    required DateTime date,
  }) async {
    final response = await _send(
      () => _client.post(
        _goalsUri.resolve('./goals/$goalId/deposits'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'amount': amount,
          'date': _dateOnly(date),
        }),
      ),
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> deleteGoal(int goalId) async {
    final response = await _send(
      () => _client.delete(_goalsUri.resolve('./goals/$goalId')),
    );
    _ensureSuccess(response);
  }

  Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const GoalApiException(
        'A API demorou para responder. Tente novamente.',
      );
    } on http.ClientException {
      throw const GoalApiException(
        'Não foi possível conectar à API. Verifique a conexão e o endereço do servidor.',
      );
    }
  }

  dynamic _decodeBody(http.Response response) {
    _ensureSuccess(response);
    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('A API retornou uma resposta inválida.');
    }
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'Não foi possível concluir a operação.';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final details = body['details'];
        if (details is Map<String, dynamic> && details.isNotEmpty) {
          message = details.values.first.toString();
        } else if (body['error'] is String) {
          message = body['error'] as String;
        }
      }
    } on FormatException {
      // Responses without JSON use the generic message.
    }
    throw GoalApiException(message);
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
