import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/create_item_schema.dart';
import 'package:gaspika_mobile/utils/date.dart';

class ShoppingService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getAvalaibleFoodCount() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtilities.getCurrentWeekNumberISO()}/available-product/count',
    );

    return response.data;
  }

  Future<List<dynamic>> getShoppingWeekItems() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtilities.getCurrentWeekNumberISO()}/available-product',
    );

    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getShoppingList(String? status, String? period) async {
    Map<String, dynamic> query = {};

    if (status != null) {
      query['status'] = status;
    }

    if (period != null) {
      query['dateInterval'] = period;
    }

    final response = await _dio.get(
      ApiConstant.SHOPPING_LISTS_ENDPOINT,
      queryParameters: query,
    );
    return response.data['results'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> generateShoppingList(
    int weekNumber,
    String? listName,
  ) async {
    final response = await _dio.post(
      ApiConstant.SHOPPING_LISTS_GENERATE_ENDPOINT,
      data: {'week_number': weekNumber, 'name': listName},
    );

    return response.data;
  }

  Future updateShoppingList(int listId, String newListName) async {
    await _dio.patch(
      '${ApiConstant.SHOPPING_LISTS_ENDPOINT}/$listId',
      data: {'name': newListName},
    );
  }

  Future updateShoppingItem(int itemId, String newListName) async {
    await _dio.patch(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/items/$itemId',
      data: {'name': newListName},
    );
  }

  Future deleteShoppingList(int listId) async {
    await _dio.delete('${ApiConstant.SHOPPING_LISTS_ENDPOINT}/$listId');
  }

  Future deleteShoppingItem(int itemId) async {
    await _dio.delete('${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/items/$itemId');
  }

  Future<List<dynamic>> getShoppingItemsById(int listId) async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/$listId/items',
    );

    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getFoodSuggestion(String query) async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/suggestion',
      queryParameters: {'food_name': query},
    );

    return response.data['data'] as List<dynamic>;
  }

  Future createShoppingItem(
    CreateShoppingItemSchema item,
    int listId,
    File? image,
  ) async {
    FormData formData = FormData.fromMap({...item.toMap()});

    if (image != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    await _dio.post(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/$listId/add',
      data: formData,
    );
  }

  Future<Map<String, dynamic>> getShoppingItemById(int itemId) async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/items/$itemId',
    );

    return response.data['data'];
  }

  Future markItemAsComplete(int itemId) async {
    await _dio.patch(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/items/$itemId/complete',
    );
  }
}
