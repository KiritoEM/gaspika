import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/date_picker.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:provider/provider.dart';
import 'package:my_toastify/my_toastify.dart';

class CreateListBottomsheet {
  static Future show(BuildContext context) async {
    final shoppingListVm = Provider.of<ShoppingListViewModel>(
      context,
      listen: false,
    );

    DateTime modalDate = shoppingListVm.selectedDate;

    return await AppBottomSheet.show(
      context: context,
      builder: (context, setModalState) {
        final shoppingListVm = context.watch<ShoppingListViewModel>();

        return [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Créer une liste de courses',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBlock(
                      label: 'Nom',
                      child: TextField(
                        controller: shoppingListVm.listNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Entrez le nom de la liste',
                        ),
                        autofocus: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    FormBlock(
                      label: 'Choisissez une date d\'une semaine',
                      child: DatePicker(
                        value: modalDate,
                        onSelectDate: (date) {
                          setModalState(() {
                            modalDate = date;
                          });
                          shoppingListVm.setSelectedDate(date);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ButtonWithLoader(
                    isLoading: shoppingListVm.isGeneratingList,
                    text: 'Créer',
                    loadingText: 'Création en cours...',
                    onPressed:
                        shoppingListVm.listNameController.text.trim().isEmpty
                        ? null
                        : () async {
                            await shoppingListVm.generateShoppingList();

                            if (!context.mounted) return;

                            Navigator.of(context).pop();

                            if (shoppingListVm.hasGenerateError) {
                              if (shoppingListVm.generateErrorType ==
                                  NetworkErrorType.conflict) {
                                Toastify.show(
                                  context,
                                  message: shoppingListVm.generateErrorMessage,
                                  type: ToastType.info,
                                );
                                return;
                              }

                              Toastify.show(
                                context,
                                message: shoppingListVm.generateErrorMessage,
                                type: ToastType.error,
                              );
                            } else {
                              Toastify.show(
                                context,
                                message: 'Liste générée avec succès',
                                type: ToastType.success,
                              );

                              await shoppingListVm.refreshShoppingList();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
