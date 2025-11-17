import 'package:snow_app/core/api_client.dart';

import '../Data/models/New Model/admin_business_category.dart';

class AdminCategoryRepository {
  final ApiClient _api = ApiClient.create();

  // 🔹 Fetch ALL categories (Admin side)
  Future<List<AdminBusinessCategory>> fetchBusinessCategories() async {
    const endpoint = "/";
    const query = {"endpoint": "admin/business-category-list"};

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200) {
        final list = (res.data['data'] as List)
            .map((e) => AdminBusinessCategory.fromJson(e))
            .toList();

        return list;
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // 🔹 Create a new category
  Future<AdminBusinessCategory> createBusinessCategory(
      String name, String description) async {
    const endpoint = "/";
    final query = {"endpoint": "admin/business-category-create"};

    try {
      final (res, code) = await _api.post(
        endpoint,
        query: query,
        body: {
          "name": name,
          "description": description,
        },
      );

      if (code == 201 || code == 200) {
        return AdminBusinessCategory(
          id: res.data['id'],
          name: name,
          description: description,
        );
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // 🔹 Delete a category
  Future<bool> deleteBusinessCategory(int id) async {
    const endpoint = "/";
    final query = {
      "endpoint": "admin/business-category-delete",
      "id": id.toString(),
    };

    try {
      final (res, code) = await _api.delete(
        endpoint,
        query: query,
      );

      if (code == 200) {
        return true;
      } else {
        throw Exception("Delete failed: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
