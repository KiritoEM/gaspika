// screens/create_shopping_item_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class CreateShoppingItemScreen extends StatelessWidget {
  final int id;

  const CreateShoppingItemScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateShoppingItemViewModel(),
      child: _CreateShoppingItemView(listId: id),
    );
  }
}

class _CreateShoppingItemView extends StatelessWidget {
  final int listId;

  const _CreateShoppingItemView({required this.listId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateShoppingItemViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Ajouter un aliment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(23, 32, 23, 23),
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    _FormBlock(
                      label: 'Nom du produit',
                      child: TextFormField(
                        initialValue: vm.name,
                        onChanged: vm.setName,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Tomates',
                        ),
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Nom requis' : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Prix
                    _FormBlock(
                      label: 'Prix (Ar)',
                      child: TextFormField(
                        initialValue: vm.price,
                        onChanged: vm.setPrice,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Ex: 3000'),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) return 'Prix requis';
                          if (double.tryParse(v!.replaceAll(',', '.')) == null)
                            return 'Prix invalide';
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quantité
                    _FormBlock(
                      label: 'Quantité',
                      child: TextFormField(
                        initialValue: vm.quantity,
                        onChanged: vm.setQuantity,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Ex: 2${vm.unit == QuantityUnit.piece ? '' : '.5'}',
                        ),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true)
                            return 'Quantité requise';
                          final q = double.tryParse(v!.replaceAll(',', '.'));
                          if (q == null || q <= 0)
                            return 'Quantité positive requise';
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _FormBlock(
                      label: 'Unité',
                      child: DropdownButtonFormField<QuantityUnit>(
                        value: vm.unit,
                        items: QuantityUnit.values.map((u) {
                          String label;
                          switch (u) {
                            case QuantityUnit.piece:
                              label = 'pièce';
                              break;
                            case QuantityUnit.kilogram:
                              label = 'kg';
                              break;
                            case QuantityUnit.gram:
                              label = 'g';
                              break;
                            case QuantityUnit.liter:
                              label = 'litre';
                              break;
                            case QuantityUnit.milliliter:
                              label = 'ml';
                              break;
                          }

                          return DropdownMenuItem<QuantityUnit>(
                            value: u,
                            child: Text(label),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          hintText: 'Sélectionner',
                        ),
                        onChanged: vm.setUnit,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notes
                    _FormBlock(
                      label: 'Notes (facultatif)',
                      child: TextFormField(
                        initialValue: vm.notes,
                        onChanged: vm.setNotes,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Écrire une note...',
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    SizedBox(
                      width: double.infinity,
                      child: ButtonWithLoader(
                        isLoading: vm.isSubmitting,
                        loadingText: 'Confirmation en cours...',
                        text: 'Confirmer',
                        onPressed: vm.isSubmitting
                            ? null
                            : () async {
                                final error = await vm.submitItemForm(listId);

                                if (!context.mounted) return;

                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Article ajouté avec succès !',
                                      ),
                                    ),
                                  );

                                  context.go('/shopping-list');
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormBlock extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
