import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../viewmodels/goal_viewmodel.dart';

Future<void> showAddDepositModal(BuildContext context, GoalModel goal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AddDepositModal(goal: goal),
  );
}

class AddDepositModal extends StatefulWidget {
  const AddDepositModal({required this.goal, super.key});

  final GoalModel goal;

  @override
  State<AddDepositModal> createState() => _AddDepositModalState();
}

class _AddDepositModalState extends State<AddDepositModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isWithdrawal = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<GoalViewModel>();
    final enteredAmount = _parseAmount(_amountController.text)!;
    final success = await viewModel.addDeposit(
      goalId: widget.goal.id,
      amount: _isWithdrawal ? -enteredAmount : enteredAmount,
      date: DateTime.now(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isWithdrawal ? 'Retirada registrada.' : 'Depósito registrado.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(viewModel.errorMessage ?? 'Não foi possível registrar a movimentação.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<GoalViewModel>().isSaving;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Movimentar cofrinho',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(widget.goal.title),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Depósito'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Retirada'),
                  icon: Icon(Icons.remove),
                ),
              ],
              selected: {_isWithdrawal},
              onSelectionChanged: (selection) =>
                  setState(() => _isWithdrawal = selection.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
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
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isWithdrawal ? 'Registrar retirada' : 'Adicionar depósito'),
            ),
          ],
        ),
      ),
    );
  }
}
