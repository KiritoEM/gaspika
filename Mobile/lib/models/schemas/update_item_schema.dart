import 'package:gaspika_mobile/constants/enums/enums.dart';

extension QuantityUnitExtension on QuantityUnit {
  String toUpperCase() {
    return name.toUpperCase();
  }
}

class UpdateShoppingItemSchema {
  String foodName = '';
  double quantity;
  QuantityUnit unit = QuantityUnit.unit;
  double price;

  UpdateShoppingItemSchema({
    required this.foodName,
    this.quantity = 0.0,
    this.unit = QuantityUnit.unit,
    this.price = 0.0,
  });

  @override
  String toString() {
    return '''
CreateShoppingItemSchema {
  foodName: "$foodName",
  quantity: ${quantity.toStringAsFixed(2)} ${unit.name},
  unit: $unit
  price: ${price.toStringAsFixed(2)}€,
}
    ''';
  }

  Map<String, dynamic> toMap() {
    return {'food_name': foodName, 'price': price, 'unit': unit.toUpperCase()};
  }
}
