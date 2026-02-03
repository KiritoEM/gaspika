// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/shared/progress_indicator.dart';
import 'package:go_router/go_router.dart';

class FinalizeShoppingItemScreen extends StatelessWidget {
  final CreateShoppingItemSchema data;

  const FinalizeShoppingItemScreen({super.key, required this.data});

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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ajouter un aliment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
      ),
      body: Column(
        children: [
          CustomProgressIndicator(value: 1),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 32, 23, 23),
                child: _buildContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // final viewModel = context.watch<CreateShoppingItemViewModel>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Text(
                'Informations complémentaires',
                style: TextStyle(
                  fontSize: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.fontSize!,
                  fontWeight: .bold,
                ),
              ),

              Text(
                'Consultez les informations relatives à la quantité recommandée et à la conservation de l’aliment.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ],
          ),

          SizedBox(height: 32),

          Column(
            children: [
              Column(
                crossAxisAlignment: .start,
                spacing: 8,
                children: [
                  Text('Quantité recommandée(kg)'),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 203, 218, 118),
                      border: BoxBorder.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(data.recommendedQuantity.toString()),
                  ),
                ],
              ),

              SizedBox(height: 24),

              Column(
                spacing: 8,
                crossAxisAlignment: .start,
                children: [
                  Text('Durée de conservation'),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 203, 218, 118),
                      border: BoxBorder.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${data.conservationDuration.toString()} jour'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
