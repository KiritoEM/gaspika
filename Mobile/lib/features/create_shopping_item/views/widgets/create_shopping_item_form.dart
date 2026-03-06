// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/analysis_overlay.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/food_autocomplete_view.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/unit_item.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:gaspika_mobile/utils/debounce_timer.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class CreateShoppingItemForm extends StatefulWidget {
  final int listId;
  final String listName;
  final int weekNumber;

  const CreateShoppingItemForm({
    super.key,
    required this.listId,
    required this.listName,
    required this.weekNumber,
  });

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

  late final Debounceable<List<ShoppingListItem>?, String> _debouncedSearch;

  Future _handleSubmitForm(
    BuildContext context,
    CreateShoppingItemViewModel createShoppingItemVm,
  ) async {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: createShoppingItemVm,
          builder: (context, child) {
            return AnalysisOverlay();
          },
        );
      },
    );

    await createShoppingItemVm.submitFormOne(widget.listId);

    if (!mounted) return;

    if (createShoppingItemVm.hasSubmitStepOneError == true) {
      Toastify.show(
        context,
        message: createShoppingItemVm.submitStepOneErrorMessage!,
        type: ToastType.error,
      );
      Navigator.of(context, rootNavigator: true).pop(true);

      return;
    }

    context.go(
      '${NavigationConstant.CREATE_SHOPPING_ITEM_ROUTE}/${widget.listId}/finalize?name=${widget.listName}&week=${widget.weekNumber}',
    );

    Navigator.of(context, rootNavigator: true).pop(true);
  }

  @override
  void initState() {
    super.initState();

    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
      listen: false,
    );

    _debouncedSearch = DebounceUtils.debounce<List<ShoppingListItem>?, String>(
      createShoppingItemVm.searchFoodName,
      const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
    );

    return Stack(
      children: [
        Form(
          key: createShoppingItemVm.formkey,
          child: Column(
            children: [
              FormBlock(
                label: 'Nom de l\'aliment',
                isRequired: true,
                child: Autocomplete<ShoppingListItem>(
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Ex: Tomate, Riz, Poulet...',
                          ),
                          focusNode: focusNode,
                          controller: textEditingController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer un nom d\'aliment';
                            }
                            return null;
                          },
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                          onSaved: (value) {
                            if (value != null) {
                              createShoppingItemVm.setName(value);
                            }
                          },
                        );
                      },
                  displayStringForOption: (ShoppingListItem option) =>
                      option.foodName,
                  optionsBuilder: (textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return [];
                    }

                    final options = await _debouncedSearch(
                      textEditingValue.text,
                    );

                    return options ?? const Iterable<ShoppingListItem>.empty();
                  },
                  optionsViewBuilder: (context, onSelected, options) =>
                      FoodAutocompleteView(
                        options: options,
                        onSelect: (option) => onSelected(option),
                      ),
                  onSelected: (option) {
                    createShoppingItemVm.setName(option.foodName);

                    // seed category select with selected food
                    createShoppingItemVm.setCategoryId(option.categoryId!);
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
                      createShoppingItemVm.setNumberOfPeople(
                        int.tryParse(value) ?? 1,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Prix(en Ariary)',
                isRequired: true,
                child: TextFormField(
                  decoration: const InputDecoration(hintText: 'Ex: 2000'),
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
                      createShoppingItemVm.setPrice(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Catégorie',
                isRequired: true,
                child: DropdownButtonFormField<int>(
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionnez une catégorie',
                  ),

                  value: createShoppingItemVm.data.categoryId == 0
                      ? null
                      : createShoppingItemVm.data.categoryId,
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
                      createShoppingItemVm.setCategoryId(value);
                      final selectedCategory = categoryData.firstWhere(
                        (cat) => cat['value'] == value,
                      );
                      createShoppingItemVm.setBackendCategory(
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
                    final isActive =
                        createShoppingItemVm.data.unit == unit['value'];
                    return Expanded(
                      child: UnitItem(
                        label: unit['label'],
                        isActive: isActive,
                        onSelect: () =>
                            createShoppingItemVm.setUnit(unit['value']),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              FormBlock(
                label: 'Méthode de conservation',
                isRequired: true,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionnez une méthode de conservation',
                  ),
                  value: createShoppingItemVm.data.humidity,
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
                      createShoppingItemVm.setHumidity(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _handleSubmitForm(context, createShoppingItemVm);
                  },
                  label: Text('Continuer'),
                  iconAlignment: .end,
                  icon: SvgPicture.asset(
                    'assets/icons/arrow-right-broken.svg',
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
