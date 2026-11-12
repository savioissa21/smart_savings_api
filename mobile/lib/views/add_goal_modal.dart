import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../viewmodels/goal_viewmodel.dart';

Future<void> showAddGoalModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const AddGoalModal(),
  );
}

Future<void> showEditGoalModal(BuildContext context, GoalModel goal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AddGoalModal(goal: goal),
  );
}

class AddGoalModal extends StatefulWidget {
  const AddGoalModal({super.key, this.goal});

  final GoalModel? goal;

  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    if (goal != null) {
      _titleController.text = goal.title;
      _amountController.text = goal.targetAmount.toString();
      _dueDate = goal.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final initialDate = _dueDate != null && !_dueDate!.isBefore(now)
        ? _dueDate!
        : now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 30),
      helpText: 'Selecione a data limite',
    );
    if (selected != null && mounted) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<GoalViewModel>();
    final goal = widget.goal;
    final success = goal == null
        ? await viewModel.createGoal(
            title: _titleController.text.trim(),
            targetAmount: _parseAmount(_amountController.text)!,
            dueDate: _dueDate!,
          )
        : await viewModel.updateGoal(
            goalId: goal.id,
            title: _titleController.text.trim(),
            targetAmount: _parseAmount(_amountController.text)!,
            dueDate: _dueDate!,
          );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goal == null
                ? 'Meta criada com sucesso.'
                : 'Meta atualizada com sucesso.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                (goal == null
                    ? 'Não foi possível criar a meta.'
                    : 'Não foi possível atualizar a meta.'),
          ),
        ),
      );
    }
  }

  double? _parseAmount(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<GoalViewModel>().isSaving;
    final dateText = _dueDate == null
        ? 'Selecione uma data'
        : '${_dueDate!.day.toString().padLeft(2, '0')}/'
            '${_dueDate!.month.toString().padLeft(2, '0')}/'
            '${_dueDate!.year}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.goal == null ? 'Nova meta' : 'Editar meta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                widget.goal == null
                    ? 'Defina seu objetivo e acompanhe cada passo.'
                    : 'Atualize os dados do seu objetivo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da meta',
                  hintText: 'Ex.: Viagem de férias',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor alvo',
                  hintText: '0,00',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  final amount = _parseAmount(value ?? '');
                  if (amount == null) return 'Informe um valor válido.';
                  if (amount <= 0) return 'O valor deve ser maior que zero.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormField<DateTime>(
                validator: (_) =>
                    _dueDate == null ? 'Selecione a data limite.' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _selectDueDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(dateText),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size.fromHeight(54),
                      ),
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 6),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.goal == null ? 'Criar meta' : 'Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
