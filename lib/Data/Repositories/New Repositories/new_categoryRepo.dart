import 'package:snow_app/Data/models/New%20Model/new_category.dart';
import 'package:snow_app/core/api_client.dart';


class BusinessCategoryRepository {
  final ApiClient apiClient = ApiClient.create();

  final String basePath = "/business/category";

  /// ✅ Add new business category
 Future<String> addCategory(NewCategoryModel category) async {
  final (res, statusCode) = await apiClient.post(basePath, body: category.toJson());
  final data = res.data;

  if (statusCode == 200 || statusCode == 201) {
    if (data['error'] != null) {
      return data['error'];
    }
    return "Category added successfully!";
  }

  throw Exception("Failed: ${data.toString()}");
}


  /// ✅ Delete category by ID
  Future<bool> deleteCategory(int id) async {
    final (res, statusCode) =
        await apiClient.delete(basePath, query: {'id': id});
    final data = res.data;
    return data['success'] == true;
  }
}
