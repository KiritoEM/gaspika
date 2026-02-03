// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/unit_item.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class CreateShoppingItemForm extends StatefulWidget {
  final int listId;

  const CreateShoppingItemForm({super.key, required this.listId});

  @override
  State<CreateShoppingItemForm> createState() => _CreateShoppingItemFormState();
}

class _CreateShoppingItemFormState extends State<CreateShoppingItemForm> {
  List<Map<String, dynamic>> unitData = [
    {'label': 'kg', 'value': QuantityUnit.kilogram},
    {'label': 'g', 'value': QuantityUnit.gram},
    {'label': 'ml', 'value': QuantityUnit.milliliter},
    {'label': 'l', 'value': QuantityUnit.liter},
    {'label': 'pièce', 'value': QuantityUnit.unit},
  ];

  List<Map<String, dynamic>> conservationMethods = [
    {'label': 'Réfrigération', 'value': 90},
    {'label': 'Congélation', 'value': 65},
    {'label': 'Séchage', 'value': 15},
    {'label': 'Déshydratation', 'value': 10},
    {'label': 'Fumage', 'value': 55},
    {'label': 'Salaison', 'value': 66},
    {'label': 'Sucrage confiture', 'value': 35},
    {'label': 'Mise sous vide', 'value': 70},
    {'label': 'Saucisson en saumure', 'value': 95},
    {'label': 'Appertisation (conserves)', 'value': 92},
    {'label': 'Fermentation', 'value': 85},
    {'label': 'Stockage sec (céréales)', 'value': 40},
  ];

  final List<Map<String, dynamic>> categoryData = [
    {
      'value': 1,
      'label': 'Fruits et Légumes',
      'backendCategory': 'fruit_legume',
    },
    {'value': 2, 'label': 'Boulangerie', 'backendCategory': 'cereale'},
    {'value': 3, 'label': 'Viande et Poisson', 'backendCategory': 'poisson'},
    {'value': 4, 'label': 'Produits Laitiers', 'backendCategory': 'laitier'},
    {'value': 5, 'label': 'Épicerie', 'backendCategory': 'cereale'},
    {'value': 6, 'label': 'Boissons', 'backendCategory': 'autre'},
    {'value': 7, 'label': 'Entretien', 'backendCategory': 'autre'},
  ];

  @override
  Widget build(BuildContext context) {
    final createItemVm = context.watch<CreateShoppingItemViewModel>();

    return Stack(
      children: [
        Form(
          key: createItemVm.formkey,
          child: Column(
            children: [
              FormBlock(
                label: 'Nom de l\'aliment',
                isRequired: true,
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ex: Tomate, Riz, Poulet...',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un nom d\'aliment';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      createItemVm.setName(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Nombre de personnes',
                isRequired: true,
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ex: 4',
                    suffixIcon: Icon(Icons.people_outline),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer le nombre de personnes';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      createItemVm.setNumberOfPeople(int.tryParse(value) ?? 1);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Catégorie',
                isRequired: true,
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    hintText: 'Sélectionnez une catégorie',
                  ),
                  value: createItemVm.data.categoryId == 0
                      ? null
                      : createItemVm.data.categoryId,
                  items: categoryData.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['value'],
                      child: Text(category['label']),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      createItemVm.setCategoryId(value);
                      final selectedCategory = categoryData.firstWhere(
                        (cat) => cat['value'] == value,
                      );
                      createItemVm.setBackendCategory(
                        selectedCategory['backendCategory'],
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Unité',
                isRequired: true,
                child: Row(
                  children: unitData.map((unit) {
                    final isActive = createItemVm.data.unit == unit['value'];
                    return Expanded(
                      child: UnitItem(
                        label: unit['label'],
                        isActive: isActive,
                        onSelect: () => createItemVm.setUnit(unit['value']),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Méthode de conservation',
                isRequired: false,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionnez une méthode de conservation',
                  ),
                  value: createItemVm.data.humidity,
                  items: conservationMethods.map((method) {
                    return DropdownMenuItem<int>(
                      value: method['value'],
                      child: Text(
                        method['label'],
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      createItemVm.setHumidity(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ButtonWithLoader(
                  isLoading: createItemVm.isPredicting,
                  text: 'Continuer',
                  loadingText: 'Chargement...',
                  onPressed: () async {
                    final message = await createItemVm.submitForm(
                      widget.listId,
                    );

                    if (!mounted) return;

                    if (message != null) {
                      Toastify.show(context, message: message);
                      return;
                    }

                    context.go(
                      NavigationConstant.FINALIZE_CREATE_SHOPPING_ITEM_ROUTE,
                      extra: createItemVm.data,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
