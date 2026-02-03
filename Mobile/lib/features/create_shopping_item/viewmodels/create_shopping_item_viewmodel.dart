import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/ml_model.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';

class CreateShoppingItemViewModel extends ChangeNotifier {
  final MlModel _mlModel = MlModel();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  CreateShoppingItemSchema _data = CreateShoppingItemSchema(
    foodName: '',
    personNumber: 1,
    categoryId: 0,
  );

  bool _isPredicting = false;

  CreateShoppingItemSchema get data => _data;

  bool get isPredicting => _isPredicting;
  GlobalKey<FormState> get formkey => _formkey;

  void setName(String value) {
    _data.foodName = value.trim();
    notifyListeners();
  }

  void setPrice(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    _data.price = double.tryParse(cleaned) ?? 0.0;
    notifyListeners();
  }

  void setNumberOfPeople(int value) {
    _data.personNumber = value;
    notifyListeners();
  }

  void setQuantity(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    _data.recommendedQuantity = double.tryParse(cleaned) ?? 0.0;
    notifyListeners();
  }

  void setUnit(QuantityUnit? unit) {
    if (unit != null) {
      _data.unit = unit;
      notifyListeners();
    }
  }

  void setNotes(String value) {
    _data.notes = value.trim();
    notifyListeners();
  }

  void setStorageTips(String value) {
    _data.storageTips = value.trim();
    notifyListeners();
  }

  void setCategoryId(int id) {
    _data.categoryId = id;
    notifyListeners();
  }

  void setHumidity(int humidity) {
    _data.humidity = humidity;
    notifyListeners();
  }

  void setBackendCategory(String category) {
    _data.backendCategory = category;
    notifyListeners();
  }

  Future<String?> submitForm(int listId) async {
    _isPredicting = true;
    notifyListeners();

    if (!_formkey.currentState!.validate()) {
      notifyListeners();
      return 'Veuillez remplir tous les champs requis';
    }

    _formkey.currentState!.save();

    final results = await Future.wait([
      _mlModel.predictQuantity(_data),
      _mlModel.predictConservationDuration(_data),
    ]);

    final quantityResponse = results[0];
    final conservationResponse = results[1];

    _isPredicting = false;
    notifyListeners();

    if (quantityResponse.hasError == true) {
      _isPredicting = false;
      notifyListeners();
      return quantityResponse.message ??
          'Erreur lors de la prédiction de quantité';
    }

    if (conservationResponse.hasError == true) {
      _isPredicting = false;
      notifyListeners();
      return conservationResponse.message ??
          'Erreur lors de la prédiction de conservation';
    }

    if (quantityResponse.data != null) {
      final predictedQuantity = quantityResponse.data!['predicted_quantity'];
      if (predictedQuantity != null) {
        _data.recommendedQuantity = (predictedQuantity as num).toDouble();
      }
    }

    if (conservationResponse.data != null) {
      final conservationDuration =
          conservationResponse.data!['conservation_duration'];
      if (conservationDuration != null) {
        _data.conservationDuration = (conservationDuration as num).toInt();
      }
    }

    _isPredicting = false;
    notifyListeners();

    return null;
  }
}
