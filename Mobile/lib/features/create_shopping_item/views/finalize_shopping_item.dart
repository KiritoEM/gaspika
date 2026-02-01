import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:go_router/go_router.dart';

class FinalizeShoppingItemScreen extends StatefulWidget {
  const FinalizeShoppingItemScreen({super.key});

  @override
  State<FinalizeShoppingItemScreen> createState() =>
      _FinalizeShoppingItemScreenState();
}

class _FinalizeShoppingItemScreenState
    extends State<FinalizeShoppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recommendedQuantityController = TextEditingController();
  final _storageTipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Valeurs par défaut
    _recommendedQuantityController.text = '1';
    _storageTipsController.text = 'Conserver au frais';
  }

  @override
  void dispose() {
    _recommendedQuantityController.dispose();
    _storageTipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Finaliser la création',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(23, 32, 23, 23),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        'Quantité estimée',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextFormField(
                        controller: _recommendedQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Ex: 5'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la quantité estimée';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        'Conseils de conservation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextFormField(
                        controller: _storageTipsController,
                        decoration: const InputDecoration(
                          hintText:
                              'Ex: Conserver au réfrigérateur, à l\'abri de la lumière...',
                        ),
                        minLines: 4,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer les conseils de conservation';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Créer l\'aliment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final recommendedQuantity = _recommendedQuantityController.text;
      final storageTips = _storageTipsController.text;

      print('Estimated Quantity: $recommendedQuantity');
      print('Storage Tips: $storageTips');

      // TODO: Appeler le ViewModel pour finaliser l'item
      context.pop();
    }
  }
}
