import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_savings/services/goal_api.dart';

void main() {
  test('GoalApiService uses the Spring API routes and JSON contract', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'id': 4,
              'title': 'Reserva',
              'targetAmount': 500,
              'currentAmount': 0,
              'dueDate': '2027-01-30',
              'status': 'EM_ANDAMENTO',
              'deposits': [],
            }
          ]),
          200,
        );
      }
      return http.Response('', request.method == 'DELETE' ? 204 : 201);
    });
    final api = GoalApiService(
      client: client,
      baseUrl: 'http://localhost:8080/api',
    );

    final goals = await api.fetchGoals();
    await api.addDeposit(
      goalId: 4,
      amount: -25,
      date: DateTime(2026, 11, 12),
    );
    await api.createGoal(
      title: 'Viagem',
      targetAmount: 1200,
      dueDate: DateTime(2027, 6, 1),
    );
    await api.updateGoal(
      goalId: 4,
      title: 'Viagem atualizada',
      targetAmount: 1500,
      dueDate: DateTime(2027, 7, 1),
    );
    await api.deleteGoal(4);

    expect(goals.single.title, 'Reserva');
    expect(
      requests.map((request) => '${request.method} ${request.url.path}'),
      [
        'GET /api/goals',
        'POST /api/goals/4/deposits',
        'POST /api/goals',
        'PUT /api/goals/4',
        'DELETE /api/goals/4',
      ],
    );
    expect(jsonDecode(requests[1].body), {
      'amount': -25.0,
      'date': '2026-11-12',
    });
    expect(jsonDecode(requests[2].body), {
      'title': 'Viagem',
      'targetAmount': 1200.0,
      'dueDate': '2027-06-01',
    });
    expect(jsonDecode(requests[3].body), {
      'title': 'Viagem atualizada',
      'targetAmount': 1500.0,
      'dueDate': '2027-07-01',
    });
    client.close();
  });
}
