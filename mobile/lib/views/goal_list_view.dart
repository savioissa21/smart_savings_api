import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../viewmodels/goal_viewmodel.dart';
import 'add_deposit_modal.dart';
import 'add_goal_modal.dart';

class GoalListView extends StatelessWidget {
  const GoalListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Savings',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Seus planos, mais perto.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                tooltip: 'Criar nova meta',
                onPressed: () => showAddGoalModal(context),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Em andamento'),
              Tab(text: 'Concluídas'),
            ],
          ),
        ),
        body: Consumer<GoalViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading && viewModel.goals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.errorMessage != null && viewModel.goals.isEmpty) {
              return _LoadError(
                message: viewModel.errorMessage!,
                onRetry: viewModel.loadGoals,
              );
            }

            return TabBarView(
              children: [
                _GoalTab(
                  goals: viewModel.activeGoals,
                  totalSaved: viewModel.totalSaved,
                  isLoading: viewModel.isLoading,
                  isCompletedTab: false,
                  onRefresh: viewModel.loadGoals,
                ),
                _GoalTab(
                  goals: viewModel.completedGoals,
                  totalSaved: viewModel.totalSaved,
                  isLoading: viewModel.isLoading,
                  isCompletedTab: true,
                  onRefresh: viewModel.loadGoals,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoalTab extends StatelessWidget {
  const _GoalTab({
    required this.goals,
    required this.totalSaved,
    required this.isLoading,
    required this.isCompletedTab,
    required this.onRefresh,
  });

  final List<GoalModel> goals;
  final double totalSaved;
  final bool isLoading;
  final bool isCompletedTab;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GoalViewModel>();
    final activeCount = viewModel.activeGoals.length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _SavingsSummary(
            totalSaved: totalSaved,
            activeCount: activeCount,
          ),
          if (isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (viewModel.errorMessage != null && viewModel.goals.isNotEmpty) ...[
            const SizedBox(height: 12),
            MaterialBanner(
              content: Text(viewModel.errorMessage!),
              actions: [
                TextButton(
                  onPressed: onRefresh,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  isCompletedTab ? 'Metas concluídas' : 'Metas ativas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${goals.length} ${goals.length == 1 ? 'meta' : 'metas'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            _EmptyState(isCompletedTab: isCompletedTab)
          else
            ...goals.map((goal) => _GoalCard(goal: goal)),
        ],
      ),
    );
  }
}

class _SavingsSummary extends StatelessWidget {
  const _SavingsSummary({
    required this.totalSaved,
    required this.activeCount,
  });

  final double totalSaved;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF176B57), Color(0xFF25866C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.savings_outlined, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'TOTAL GUARDADO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currency.format(totalSaved),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$activeCount ${activeCount == 1 ? 'meta em andamento' : 'metas em andamento'}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final date = DateFormat('dd/MM/yyyy', 'pt_BR').format(goal.dueDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (goal.isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.check_circle, color: Color(0xFF176B57)),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Ações da meta',
                  onSelected: (action) {
                    if (action == 'delete') _confirmDelete(context);
                    if (action == 'edit') showEditGoalModal(context, goal);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar meta'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Excluir meta'),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 9,
                backgroundColor: const Color(0xFFE8EFEA),
                color: const Color(0xFF25866C),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${currency.format(goal.currentAmount)} de ${currency.format(goal.targetAmount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Até $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showAddDepositModal(context, goal),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Movimentar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text(
          'A meta "${goal.title}" e seu histórico de movimentações serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final viewModel = context.read<GoalViewModel>();
    final success = await viewModel.deleteGoal(goal.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Meta excluída.'
              : viewModel.errorMessage ?? 'Não foi possível excluir a meta.',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isCompletedTab});

  final bool isCompletedTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            isCompletedTab ? Icons.emoji_events_outlined : Icons.savings_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            isCompletedTab ? 'Ainda sem metas concluídas' : 'Comece a guardar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isCompletedTab
                ? 'Suas conquistas vão aparecer aqui.'
                : 'Crie uma meta e acompanhe seu progresso.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
