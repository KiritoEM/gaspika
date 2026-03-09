// models/schemas/create_item.dart

import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/category.dart';

extension QuantityUnitExtension on QuantityUnit {
  String toUpperCase() {
    return name.toUpperCase();
  }
}

class CreateShoppingItemSchema {
  String foodName = '';
  double recommendedQuantity;
  QuantityUnit unit = QuantityUnit.unit;
  double price;
  String notes;
  int personNumber;
  String? storageTips;
  int humidity;
  int? conservationDuration;
  Category? category;
  String mealFrequency;
  int consumptionDuration;

  CreateShoppingItemSchema({
    required this.foodName,
    required this.personNumber,
    required this.consumptionDuration,
    this.recommendedQuantity = 0.0,
    this.unit = QuantityUnit.unit,
    this.price = 0.0,
    this.notes = '',
    this.storageTips = '',
    this.category,
    this.humidity = 98,
    this.conservationDuration,
    this.mealFrequency = 'petit_dejeuner',
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
  categoryId: ${category?.id},
  backendCategory: "${category?.mlCategory}",
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
      'food_category_id': category?.id,
      'storage_tips': storageTips,
      'default_shelf_life_day': conservationDuration,
    };
  }
}
