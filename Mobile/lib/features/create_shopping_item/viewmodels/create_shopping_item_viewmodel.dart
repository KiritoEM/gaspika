import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/ml_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:image_picker/image_picker.dart';

class CreateShoppingItemViewModel extends ChangeNotifier {
  final MlModel _mlModel = MlModel();
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final CreateShoppingItemSchema _data = CreateShoppingItemSchema(
    foodName: '',
    personNumber: 1,
    categoryId: 0,
  );

  bool _isPredicting = false;
  bool _isCreating = false;
  File? _image;
  String? _uploadImageError;

  // getters
  CreateShoppingItemSchema get data => _data;
  bool get isPredicting => _isPredicting;
  bool get isCreating => _isCreating;
  GlobalKey<FormState> get formkey => _formkey;
  File? get image => _image;
  String? get uploadImageError => _uploadImageError;

  //form setters
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

  // pick image
  Future<void> pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 1920,
        maxWidth: 1920,
      );

      if (picked != null) {
        final file = File(picked.path);
        final fileSize = await file.length();

        // Vérifier la taille (10MB max)
        if (fileSize > 10 * 1024 * 1024) {
          _uploadImageError = 'L\'image est trop volumineuse (max 10MB)';
          _image = null;
        } else {
          _image = file;
          _uploadImageError = null;
        }
        notifyListeners();
      }
    } catch (e) {
      _uploadImageError = 'Erreur lors du chargement de l\'image';
      AppLogger.logger.e('Error picking image: $e');
      notifyListeners();
    }
  }

  // remove image preview
  void removeImage() {
    _image = null;
    _uploadImageError = null;
    notifyListeners();
  }

  // Make prediction (form step 1)
  Future<String?> submitFormOne(int listId) async {
    _isPredicting = true;
    notifyListeners();

    if (!_formkey.currentState!.validate()) {
      _isPredicting = false;
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

    AppLogger.logger.i(
      'quantite: ${quantityResponse.data}  conservation: ${conservationResponse.data}',
    );

    if (quantityResponse.data != null) {
      final predictedQuantity = quantityResponse.data!['quantite_recommandee'];
      if (predictedQuantity != null) {
        _data.recommendedQuantity = (predictedQuantity as num).toDouble();
      }
    }

    if (conservationResponse.data != null) {
      final conservationDuration =
          conservationResponse.data!['duree_conservation_jours'];
      if (conservationDuration != null) {
        _data.conservationDuration = (conservationDuration as num).floor();
      }
    }

    _isPredicting = false;
    notifyListeners();

    return null;
  }

  // Create aliment (form step 2)
  Future<String?> createAliment(int listId) async {
    if (_image == null) {
      return 'Veuillez sélectionner une image';
    }

    _isCreating = true;
    notifyListeners();

    try {
      final response = await _shoppingItemsModel.createShoppingItem(
        _data,
        listId,
        _image!,
      );

      _isCreating = false;
      notifyListeners();

      if (response.hasError == true) {
        return response.message ?? 'Erreur lors de la création de l\'aliment';
      }

      notifyListeners();

      return null;
    } catch (e) {
      _isCreating = false;
      notifyListeners();

      AppLogger.logger.e('Unexpected error creating aliment: $e');
      return 'Erreur inattendue lors de la création de l\'aliment';
    }
  }
}
