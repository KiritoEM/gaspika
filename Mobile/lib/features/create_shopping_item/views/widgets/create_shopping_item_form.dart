// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/shared/loader_with_overlay.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/food_autocomplete_view.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/selectable_item.dart';
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
    {'label': 'Mettre au réfrigérateur', 'value': 98},
    {'label': 'Mettre sous vide', 'value': 97},
    {'label': 'Mettre en bocal (saumure)', 'value': 91},
    {'label': 'Mettre en conserve', 'value': 90},
    {'label': 'Fermenter', 'value': 88},
    {'label': 'Saler et sécher', 'value': 87},
    {'label': 'Fumer', 'value': 85},
    {'label': 'Mettre au congélateur', 'value': 80},
    {'label': 'Faire une confiture', 'value': 75},
    {'label': 'Faire sécher', 'value': 65},
    {'label': 'Stocker au sec', 'value': 62},
    {'label': 'Déshydrater', 'value': 58},
  ];

  List<Map<String, dynamic>> mealFrequency = [
    {'label': 'Petit déjeuner', 'value': 'petit_dejeuner'},
    {'label': 'Déjeuner', 'value': 'dejeuner'},
    {'label': 'Dîner', 'value': 'diner'},
    {'label': 'Collation', 'value': 'collation'},
  ];

  late final Debounceable<List<ShoppingListItem>?, String> _debouncedSearch;

  Future _handleSubmitForm(
    BuildContext context,
    CreateShoppingItemViewModel createShoppingItemVm,
  ) async {
    if (!createShoppingItemVm.formkey.currentState!.validate()) return;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useRootNavigator: true,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return LoaderWithOverlay(text: 'Analyse en cours');
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

    context.push(
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

    createShoppingItemVm.getAllCategories();

    _debouncedSearch = DebounceUtils.debounce<List<ShoppingListItem>?, String>(
      createShoppingItemVm.searchFoodName,
      const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
    );

    return Form(
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

                final options = await _debouncedSearch(textEditingValue.text);

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
                createShoppingItemVm.setCategory(
                  categoryId: option.category.id,
                  categoryName: option.category.name,
                  mlCategory: option.category.mlCategory,
                );
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
            isLoading: createShoppingItemVm.isLoadingCategories,
            child: DropdownButtonFormField<int>(
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Sélectionnez une catégorie',
              ),

              value: createShoppingItemVm.data.category?.id == null
                  ? null
                  : createShoppingItemVm.data.category!.id,
              items: createShoppingItemVm.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              },
              onChanged: (value) {
                if (value != null) {
                  final selectedCategory = createShoppingItemVm.categories
                      .firstWhere((cat) => cat.id == value);

                  createShoppingItemVm.setCategory(
                    categoryId: value,
                    mlCategory: selectedCategory.mlCategory,
                    categoryName: selectedCategory.name,
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          FormBlock(
            label: 'Nombre de consommateurs',
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
            label: 'Jour de consommation (1-7 jours)',
            isRequired: true,
            child: TextFormField(
              decoration: const InputDecoration(hintText: '2'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le nombre de jours de consommation';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0 || number > 7) {
                  return 'Veuillez entrer un nombre valide entre 1 et 7';
                }

                return null;
              },
              onSaved: (value) {
                if (value != null) {
                  createShoppingItemVm.setConsumptionDuration(
                    int.tryParse(value) ?? 1,
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          FormBlock(
            label: 'Unité',
            isRequired: true,
            child: Wrap(
              children: unitData.map((unit) {
                final isActive =
                    createShoppingItemVm.data.unit == unit['value'];

                return FittedBox(
                  child: SelectableItem(
                    label: unit['label'],
                    isActive: isActive,
                    onSelect: () => createShoppingItemVm.setUnit(unit['value']),
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

          const SizedBox(height: 24),

          FormBlock(
            label: 'Fréquence de repas',
            isRequired: true,
            child: Wrap(
              children: mealFrequency.map((freq) {
                final isActive =
                    createShoppingItemVm.data.mealFrequency == freq['value'];

                return FittedBox(
                  child: SelectableItem(
                    label: freq['label'],
                    isActive: isActive,
                    onSelect: () =>
                        createShoppingItemVm.setMealFrequency(freq['value']),
                  ),
                );
              }).toList(),
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
    );
  }
}
