// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/finalize_shopping_item_form.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/stepper_header.dart';
import 'package:gaspika_mobile/shared/progress_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FinalizeShoppingItemScreen extends StatefulWidget {
  final String listId;
  final String listName;
  final int weekNumber;

  const FinalizeShoppingItemScreen({
    super.key,
    required this.listId,
    required this.listName,
    required this.weekNumber,
  });

  @override
  State<FinalizeShoppingItemScreen> createState() =>
      _FinalizeShoppingItemScreenState();
}

class _FinalizeShoppingItemScreenState
    extends State<FinalizeShoppingItemScreen> {
  @override
  void initState() {
    super.initState();

    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
      listen: false,
    );

    // init quantity input default value
    createShoppingItemVm.quantityController.text = createShoppingItemVm
        .data
        .recommendedQuantity
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          onPressed: () => context.pop(true),
        ),
        title: const Text(
          'Ajouter un aliment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
      ),
      body: Column(
        children: [
          CustomProgressIndicator(activeIndex: 1),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                child: _buildContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Header
            StepperHeader(
              title: 'Informations complémentaires',
              description:
                  'Consultez les informations prédites et téléchargez une image de l\'aliment pour finaliser l\'ajout.',
            ),

            SizedBox(height: 32),

            FinalizeShoppingItemForm(
              listId: widget.listId,
              listName: widget.listName,
              weekNumber: widget.weekNumber,
            ),
          ],
        ),
      ),
    );
  }
}
