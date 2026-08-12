import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';

class FoodAutocompleteView extends StatelessWidget {
  final Iterable<ShoppingListItem> options;
  final Function(ShoppingListItem option) onSelect;

  const FoodAutocompleteView({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .topLeft,
      child: Material(
        elevation: 3,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);

              return ListTile(
                dense: true,
                title: Text(option.foodName),
                subtitle: Text(
                  option.category.name,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                onTap: () => onSelect(option),
              );
            },
          ),
        ),
      ),
    );
  }
}
