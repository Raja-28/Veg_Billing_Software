import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';

class FarmersScreen extends ConsumerWidget {
  const FarmersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmersAsyncValue = ref.watch(farmersStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Farmer Accounts',
                  style: FluentTheme.of(context).typography.title),
              FilledButton(
                child: const Text('Add New Farmer'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddFarmerDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: farmersAsyncValue.when(
              data: (farmers) {
                if (farmers.isEmpty) {
                  return const Center(
                      child: Text('No farmers found. Add one to get started.'));
                }
                return ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = farmers[index];

                  },
                );
              },
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(child: ProgressRing()),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFarmerDialog extends ConsumerStatefulWidget {
  const AddFarmerDialog({super.key});

  @override
  ConsumerState<AddFarmerDialog> createState() => _AddFarmerDialogState();
}

class _AddFarmerDialogState extends ConsumerState<AddFarmerDialog> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(dbProvider);
      final newFarmer = FarmersCompanion(
        name: Value(_nameController.text),
        mobileNumber: Value(_mobileController.text),
      );
      db.into(db.farmers).insert(newFarmer);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add New Farmer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Farmer Name'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _nameController,
              placeholder: 'Enter farmer\'s full name',
              validator: (value) =>
              (value == null || value.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Mobile Number (for WhatsApp)'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _mobileController,
              placeholder: 'Enter 10-digit mobile number',
              validator: (value) => (value == null || value.length < 10)
                  ? 'Valid number is required'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save Farmer'),
        ),
      ],
    );
  }
}
