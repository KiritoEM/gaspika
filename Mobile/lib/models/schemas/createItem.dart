// models/schemas/createItem.dart

import 'package:gaspika_mobile/constants/enums/enums.dart';

extension QuantityUnitExtension on QuantityUnit {
  String toUpperCase() {
    return name.toUpperCase();
  }
}

class CreateShoppingItemSchema {
  String foodName = '';
  double recommendedQuantity = 0.0;
  QuantityUnit unit = QuantityUnit.unit;
  double price = 0.0;
  String notes = '';
  int personNumber = 1;
  String storageTips = '';
  int categoryId = 0;
  int humidity = 10;
  String backendCategory = '';
  int? conservationDuration;

  CreateShoppingItemSchema({
    required this.foodName,
    this.recommendedQuantity = 0.0,
    this.unit = QuantityUnit.unit,
    this.price = 0.0,
    this.notes = '',
    required this.personNumber,
    this.storageTips = '',
    required this.categoryId,
    this.humidity = 10,
    this.backendCategory = '',
    this.conservationDuration,
  });

  @override
  String toString() {
    return '''
CreateShoppingItemSchema {
  foodName: "$foodName",
  recommendedQuantity: ${recommendedQuantity.toStringAsFixed(2)} ${unit.name},
  unit: $unit
  price: ${price.toStringAsFixed(2)}€,
  personNumber: $personNumber,
  categoryId: $categoryId,
  backendCategory: "$backendCategory",
  humidity: $humidity%,
  notes: "$notes",
  storageTips: "$storageTips"
}
    ''';
  }

  Map<String, dynamic> toMap() {
    return {
      'food_name': foodName,
      'quantity': recommendedQuantity,
      'price': price,
      'person_number': personNumber,
      'unit': unit.toUpperCase(),
      'food_category_id': categoryId,
    };
  }
}
