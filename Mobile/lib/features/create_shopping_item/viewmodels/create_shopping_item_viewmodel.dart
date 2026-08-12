import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/categories_model.dart';
import 'package:gaspika_mobile/models/domains-object/category.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/ml_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/models/schemas/create_item_schema.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:image_picker/image_picker.dart';

class CreateShoppingItemViewModel extends ChangeNotifier {
  final MlModel _mlModel = MlModel();
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();
  final CategoriesModel _categoriesModel = CategoriesModel();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController quantityController = TextEditingController(text: '');

  final CreateShoppingItemSchema _data = CreateShoppingItemSchema(
    foodName: '',
    personNumber: 1,
    consumptionDuration: 1,
  );

  File? _image;
  bool _isPredicting = false;
  bool _isCreating = false;
  String _uploadImageErrorMessage = '';
  bool _hasSubmitStepOneError = false;
  String _submitStepOneErrorMessage = '';
  NetworkErrorType? _submitStepOneErrorType;
  bool _hasCreateFoodError = false;
  String _createFoodErrorMessage = '';
  NetworkErrorType? _createFoodErrorType;
  bool _isLoadingCategories = false;
  List<Category> _categories = [];
  String _fetchCategoriesErrorMessage = '';
  bool _hasFetchCategoriesError = false;
  NetworkErrorType? _fetchCategoriesErrorType;

  // getters
  CreateShoppingItemSchema get data => _data;
  bool get isPredicting => _isPredicting;
  bool get isCreating => _isCreating;
  GlobalKey<FormState> get formkey => _formkey;
  File? get image => _image;
  String get uploadImageErrorMessage => _uploadImageErrorMessage;
  String? get submitStepOneErrorMessage => _submitStepOneErrorMessage;
  bool get hasSubmitStepOneError => _hasSubmitStepOneError;
  NetworkErrorType? get submitStepOneErrorType => _submitStepOneErrorType;
  bool get hasCreateFoodError => _hasCreateFoodError;
  String? get createFoodErrorMessage => _createFoodErrorMessage;
  NetworkErrorType? get createFoodErrorType => _createFoodErrorType;
  bool get isLoadingCategories => _isLoadingCategories;
  List<Category> get categories => _categories;
  String? get fetchCategoriesErrorMessage => _fetchCategoriesErrorMessage;
  bool get hasFetchCategoriesError => _hasFetchCategoriesError;
  NetworkErrorType? get fetchCategoriesErrorType => _fetchCategoriesErrorType;

  //form setters
  void setName(String value) {
    _data.foodName = value.trim();
    notifyListeners();
  }

  void setPrice(String value) {
    _data.price = int.tryParse(value) ?? 0;
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

  void setHumidity(int humidity) {
    _data.humidity = humidity;
    notifyListeners();
  }

  void setMealFrequency(String mealFrequency) {
    _data.mealFrequency = mealFrequency;
    notifyListeners();
  }

  void setConsumptionDuration(int consumptionDuration) {
    _data.consumptionDuration = consumptionDuration;
    notifyListeners();
  }

  void setCategory({
    required int categoryId,
    required String categoryName,
    required String mlCategory,
  }) {
    if (_data.category == null) {
      _data.category = Category(
        id: categoryId,
        name: categoryName,
        mlCategory: mlCategory,
      );
    } else {
      _data.category = _data.category!.copyWith(
        id: categoryId,
        name: categoryName,
        mlCategory: mlCategory,
      );
    }

    notifyListeners();
  }

  // pick image
  Future pickImage() async {
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

        if (fileSize > 10 * 1024 * 1024) {
          _uploadImageErrorMessage = 'L\'image est trop volumineuse (max 10MB)';
          _image = null;
        } else {
          _image = file;
          _uploadImageErrorMessage = '';
        }
        notifyListeners();
      }
    } catch (e) {
      _uploadImageErrorMessage = 'Erreur lors du chargement de l\'image';
      AppLogger.logger.e('Error picking image: $e');
      notifyListeners();
    }
  }

  // remove image preview
  void removeImage() {
    _image = null;
    _uploadImageErrorMessage = '';
    notifyListeners();
  }

  // Make prediction (form step 1)
  Future submitFormOne(int listId) async {
    _hasSubmitStepOneError = false;
    _submitStepOneErrorMessage = '';
    _submitStepOneErrorType = null;

    _isPredicting = true;
    notifyListeners();

    if (!_formkey.currentState!.validate()) {
      _isPredicting = false;
      notifyListeners();
      return;
    }

    _formkey.currentState!.save();

    // predict quantity and conservation duration
    final results = await Future.wait([
      _mlModel.predictQuantity(_data),
      _mlModel.predictConservationDuration(_data),
    ]);

    final quantityResponse = results[0];
    final conservationResponse = results[1];

    if (quantityResponse.hasError == true) {
      _isPredicting = false;
      _submitStepOneErrorMessage = quantityResponse.message!;
      notifyListeners();

      return;
    }

    if (conservationResponse.hasError == true) {
      _isPredicting = false;
      _submitStepOneErrorMessage = conservationResponse.message!;
      notifyListeners();

      return;
    }

    if (quantityResponse.data != null) {
      final predictedQuantity = quantityResponse.data!['quantite_recommandee'];
      if (predictedQuantity != null) {
        if (_data.unit == QuantityUnit.gram ||
            _data.unit == QuantityUnit.milliliter) {
          _data.recommendedQuantity = ((predictedQuantity as num) * 1000)
              .toDouble();
        } else {
          _data.recommendedQuantity = (predictedQuantity as num).toDouble();
        }
      }
    }

    if (conservationResponse.data != null) {
      final conservationDuration =
          conservationResponse.data!['duree_conservation_jours'];
      if (conservationDuration != null) {
        _data.conservationDuration = (conservationDuration as num).floor();
      }

      final conservationRecommandation =
          conservationResponse.data!['interpretation'];
      if (conservationRecommandation != null) {
        _data.storageTips = conservationRecommandation;
      }
    }

    _isPredicting = false;
    notifyListeners();
  }

  // Create aliment (form step 2)
  Future createAliment(int listId) async {
    _isCreating = true;
    _hasCreateFoodError = false;
    _createFoodErrorMessage = '';
    _createFoodErrorType = null;
    notifyListeners();

    // if quantity was changed then change the final data quantity
    if (_data.recommendedQuantity != double.tryParse(quantityController.text)) {
      setQuantity(quantityController.text);
    }

    final response = await _shoppingItemsModel.createShoppingItem(
      _data,
      listId,
      _image,
    );

    if (response.hasError == true) {
      _hasCreateFoodError = true;
      _createFoodErrorMessage = response.message!;
      _createFoodErrorType = response.errorType!;
      notifyListeners();

      return;
    }

    notifyListeners();

    _isCreating = false;
    notifyListeners();
  }

  // get food suggestions
  Future<List<ShoppingListItem>> searchFoodName(String query) async {
    final response = await _shoppingItemsModel.getFoodSuggestion(query);

    if (response.hasError == true) {
      return [];
    }

    return response.data!;
  }

  // get categories
  Future getAllCategories() async {
    _isLoadingCategories = true;
    _hasFetchCategoriesError = false;
    _fetchCategoriesErrorMessage = '';
    _fetchCategoriesErrorType = null;
    notifyListeners();

    final response = await _categoriesModel.getAllCategories();

    if (response.hasError == true) {
      _isLoadingCategories = false;
      _hasFetchCategoriesError = true;
      _fetchCategoriesErrorMessage = response.message!;
      _fetchCategoriesErrorType = response.errorType!;
      notifyListeners();
    }

    _isLoadingCategories = false;
    _categories = response.data!;
    notifyListeners();
  }

  // refresh when an error occurs when fetching categories
  void refreshCategories() {
    _hasFetchCategoriesError = false;
    _fetchCategoriesErrorMessage = '';
    _fetchCategoriesErrorType = null;

    notifyListeners();
    getAllCategories();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }
}
