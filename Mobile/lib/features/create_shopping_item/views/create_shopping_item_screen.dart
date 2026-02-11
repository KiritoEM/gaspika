// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/create_shopping_item_form.dart';
import 'package:gaspika_mobile/shared/progress_indicator.dart';
import 'package:go_router/go_router.dart';

class CreateShoppingItemScreen extends StatelessWidget {
  final String id;

  const CreateShoppingItemScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
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
          CustomProgressIndicator(value: 0.5),
          Expanded(
            child: SafeArea(
              //  if (createShoppingItemVm.isPredicting)
              // {
              //   const Positioned.fill(child: AnalysisOverlay()),
              // }
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'Informations de l’aliment',
                  style: TextStyle(
                    fontSize: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.fontSize!,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Entrez les informations principales de l’aliment que vous allez ajouter.',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ],
            ),

            SizedBox(height: 32),

            CreateShoppingItemForm(listId: int.parse(id)),
          ],
        ),
      ),
    );
  }
}
