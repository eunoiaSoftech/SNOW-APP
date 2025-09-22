import 'package:snow_app/Data/models/user.dart';
import 'package:snow_app/core/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<List<User>> getPendingUsers() async {
    try {
      final (response, statusCode) =
          await apiClient.post('/auth/pending-users');

      if (statusCode == 200 && response.data['success'] == true) {
        final users = response.data['users'] as List;
        return users.map((u) => User.fromJson(u)).toList();
      } else if (statusCode == 401) {
        // Handle Unauthorized
        throw UnauthorizedException('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to fetch pending users');
      }
    } catch (e) {
      rethrow; // Let higher layer handle it
    }
  }

  Future<bool> updateUserStatus(int userId, String status) async {
    try {
      final (response, statusCode) =
          await apiClient.post('/auth/update-status', body: {
        'user_id': userId,
        'status': status,
      });

      if (statusCode == 200 && response.data['success'] == true) {
        return true;
      } else if (statusCode == 401) {
        // Handle Unauthorized
        throw UnauthorizedException('Session expired. Please log in again.');
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Custom exception for 401
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => "UnauthorizedException: $message";
}



// import 'package:snow_app/Data/models/user.dart';
// import 'package:snow_app/core/api_client.dart';


// class UserRepository {
//   final ApiClient apiClient;

//   UserRepository(this.apiClient);

//   Future<List<User>> getPendingUsers() async {
//     final (response, statusCode) =
//         await apiClient.post('/auth/pending-users');

//     if (statusCode == 200 && response.data['success'] == true) {
//       final users = response.data['users'] as List;
//       return users.map((u) => User.fromJson(u)).toList();
//     } else {
//       throw Exception('Failed to fetch pending users');
//     }
//   }

//   Future<bool> updateUserStatus(int userId, String status) async {
//     final (response, statusCode) =
//         await apiClient.post('/auth/update-status', body: {
//       'user_id': userId,
//       'status': status,
//     });

//     return statusCode == 200 && response.data['success'] == true;
//   }
// }
