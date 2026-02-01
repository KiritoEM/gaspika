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
      return Placeholder();
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
