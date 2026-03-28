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
        final data = res.data;

        // 🔥 SAFE CHECK
        if (data is Map<String, dynamic>) {
          final rawList = data['data'];

          if (rawList is List) {
            final list = rawList
                .map((e) => AdminBusinessCategory.fromJson(
                    e as Map<String, dynamic>))
                .toList();

            return list;
          }
        }

        // If structure unexpected
        return [];
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
        final data = res.data;

        return AdminBusinessCategory(
          id: int.tryParse(data['id'].toString()) ?? 0, // 🔥 FIX
          name: name,
          description: description,
          createdAt: data['created_at']?.toString(),
          isActive: true, // newly created → active
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