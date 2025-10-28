import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:snow_app/core/api_client.dart';
import '../models/business_category.dart';

class CategoryRepository {
  final ApiClient _api = ApiClient.create();

  static const String _endpoint = '/business/category';

  /// Fetch all categories
  Future<List<BusinessCategory>> fetchCategories() async {
    try {
      final (Response res, int code) = await _api.get(_endpoint);

      if (code == 200) {
        final data = res.data is List ? res.data : jsonDecode(res.data);
        return (data as List)
            .map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(res.data['error'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

 


  /// Delete a category by id
  Future<void> deleteCategory(int id) async {
    try {
      final (Response res, int code) = await _api.delete('$_endpoint?id=$id');

      if (code == 200 && res.data['success'] == true) {
        print('✅ Category deleted successfully');
      } else {
        throw Exception(res.data['error'] ?? 'Failed to delete category');
      }
    } catch (e) {
      print('❌ Error deleting category: $e');
    }
  }
}
