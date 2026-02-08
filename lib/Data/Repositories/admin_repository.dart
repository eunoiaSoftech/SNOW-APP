// import 'package:dio/dio.dart';
// import 'package:snow_app/Data/Models/admin_igloo.dart';
// import 'package:snow_app/Data/Models/admin_module.dart';
// import 'package:snow_app/Data/Models/admin_user_entry.dart';

// import '../../core/api_client.dart';
// import '../../core/result.dart';

// class AdminRepository {
//   AdminRepository();

//   final ApiClient _api = ApiClient.create();
//   static final Uri _routerBase =
//       Uri.parse('https://mediumvioletred-chough-398772.hostingersite.com/api/v1/router.php');

//   Future<Result<List<Igloo>>> fetchIgloos() async {
//     final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/igloo-list'});
//     final (res, code) = await _api.getUri(uri);
//     if (code == 200) {
//       final data = res.data;
//       if (data is Map<String, dynamic>) {
//         final list = (data['igloos'] as List<dynamic>? ?? [])
//             .map((e) => Igloo.fromJson(e as Map<String, dynamic>))
//             .toList();
//         return Ok(list);
//       }
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<Igloo>> createIgloo(Map<String, dynamic> payload) async {
//     final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/igloo-create'});
//     final (res, code) = await _api.postUri(uri, body: payload);
//     if (code == 200 || code == 201) {
//       final data = res.data;
//       if (data is Map<String, dynamic> && data['igloo'] is Map<String, dynamic>) {
//         return Ok(Igloo.fromJson(data['igloo'] as Map<String, dynamic>));
//       }
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<List<AdminModule>>> fetchModules({String? userType}) async {
//     final params = {'endpoint': 'admin/module-list'};
//     if (userType != null && userType.isNotEmpty) {
//       params['user_type'] = userType;
//     }
//     final uri = _routerBase.replace(queryParameters: params);
//     final (res, code) = await _api.getUri(uri);
//     if (code == 200) {
//       final data = res.data;
//       if (data is Map<String, dynamic>) {
//         final list = (data['modules'] as List<dynamic>? ?? [])
//             .map((e) => AdminModule.fromJson(e as Map<String, dynamic>))
//             .toList();
//         return Ok(list);
//       }
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<void>> updateModuleAccess({
//     required String userType,
//     required int moduleId,
//     required bool isEnabled,
//   }) async {
//     final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/module-access-update'});
//     final body = {
//       'user_type': userType,
//       'module_id': moduleId,
//       'is_enabled': isEnabled ? 1 : 0,
//     };
//     final (res, code) = await _api.postUri(uri, body: body);
//     if (code == 200) {
//       return const Ok(null);
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<List<AdminUserEntry>>> fetchPendingUsers() async {
//     final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/pending-users'});
//     final (res, code) = await _api.getUri(uri);
//     if (code == 200) {
//       final data = res.data;
//       if (data is Map<String, dynamic>) {
//         final list = (data['entries'] as List<dynamic>? ?? [])
//             .map((e) => AdminUserEntry.fromJson(e as Map<String, dynamic>))
//             .toList();
//         return Ok(list);
//       }
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<List<AdminUserEntry>>> fetchUsersByStatus(String status) async {
//     final uri = _routerBase.replace(queryParameters: {
//       'endpoint': 'admin/users-by-status',
//       'status': status,
//     });
//     final (res, code) = await _api.getUri(uri);
//     if (code == 200) {
//       final data = res.data;
//       if (data is Map<String, dynamic>) {
//         final list = (data['entries'] as List<dynamic>? ?? [])
//             .map((e) => AdminUserEntry.fromJson(e as Map<String, dynamic>))
//             .toList();
//         return Ok(list);
//       }
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   Future<Result<void>> approveUser({
//     required int userTypeId,
//     required String action,
//     List<int>? iglooIds,
//   }) async {
//     final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/approve-user'});
//     final body = {
//       'user_type_id': userTypeId,
//       'action': action,
//       if (iglooIds != null) 'igloo_ids': iglooIds,
//     };
//     final (res, code) = await _api.postUri(uri, body: body);
//     if (code == 200) {
//       return const Ok(null);
//     }
//     return Err(_errorMessage(res), code: code);
//   }

//   String _errorMessage(Response res) {
//     final data = res.data;
//     if (data is Map<String, dynamic>) {
//       final msg = data['message'] ?? data['error'];
//       if (msg is String && msg.isNotEmpty) return msg;
//     }
//     return 'Request failed (${res.statusCode})';
//   }
// }


import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/admin_module.dart';
import 'package:snow_app/Data/Models/admin_user_entry.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';

class AdminRepository {
  AdminRepository();

  final ApiClient _api = ApiClient.create();
  static Uri get _routerBase =>
      Uri.parse(dotenv.env['BASE_URL'] ?? '');

  // ---------------- IGLOOS ----------------

  Future<Result<List<Igloo>>> fetchIgloos() async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/igloo-list'});

    print('\n➡️ [GET] admin/igloo-list');
    print('➡️ URI: $uri');

    final (res, code) = await _api.getUri(uri);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['igloos'] as List<dynamic>? ?? [])
            .map((e) => Igloo.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_errorMessage(res), code: code);
  }

  Future<Result<Igloo>> createIgloo(Map<String, dynamic> payload) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/igloo-create'});

    print('\n➡️ [POST] admin/igloo-create');
    print('➡️ PAYLOAD: $payload');

    final (res, code) = await _api.postUri(uri, body: payload);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200 || code == 201) {
      final data = res.data;
      if (data is Map<String, dynamic> && data['igloo'] is Map<String, dynamic>) {
        return Ok(Igloo.fromJson(data['igloo'] as Map<String, dynamic>));
      }
    }
    return Err(_errorMessage(res), code: code);
  }

  // ---------------- MODULES ----------------

  Future<Result<List<AdminModule>>> fetchModules({String? userType}) async {
    final params = {'endpoint': 'admin/module-list'};
    if (userType != null && userType.isNotEmpty) {
      params['user_type'] = userType;
    }

    final uri = _routerBase.replace(queryParameters: params);

    print('\n➡️ [GET] admin/module-list');
    print('➡️ QUERY PARAMS: $params');

    final (res, code) = await _api.getUri(uri);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['modules'] as List<dynamic>? ?? [])
            .map((e) => AdminModule.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_errorMessage(res), code: code);
  }

  Future<Result<void>> updateModuleAccess({
    required String userType,
    required int moduleId,
    required bool isEnabled,
  }) async {
    final uri = _routerBase.replace(
      queryParameters: {'endpoint': 'admin/module-access-update'},
    );

    final body = {
      'user_type': userType,
      'module_id': moduleId,
      'is_enabled': isEnabled ? 1 : 0,
    };

    print('\n➡️ [POST] admin/module-access-update');
    print('➡️ BODY: $body');

    final (res, code) = await _api.postUri(uri, body: body);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      return const Ok(null);
    }
    return Err(_errorMessage(res), code: code);
  }

  // ---------------- USERS ----------------

  Future<Result<List<AdminUserEntry>>> fetchPendingUsers() async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/pending-users'});

    print('\n➡️ [GET] admin/pending-users');
    print('➡️ URI: $uri');

    final (res, code) = await _api.getUri(uri);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['entries'] as List<dynamic>? ?? [])
            .map((e) => AdminUserEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_errorMessage(res), code: code);
  }

  /// 🚨 THIS API IS CURRENTLY FAILING
  Future<Result<List<AdminUserEntry>>> fetchUsersByStatus(String status) async {
    final uri = _routerBase.replace(queryParameters: {
      'endpoint': 'admin/users-by-status',
      'status': status,
    });

    print('\n🚨➡️ [GET] admin/users-by-status');
    print('🚨➡️ STATUS: $status');
    print('🚨➡️ URI: $uri');

    final (res, code) = await _api.getUri(uri);

    print('❌ RESPONSE CODE: $code');
    print('❌ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['entries'] as List<dynamic>? ?? [])
            .map((e) => AdminUserEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_errorMessage(res), code: code);
  }

  Future<Result<void>> approveUser({
    required int userTypeId,
    required String action,
    List<int>? iglooIds,
  }) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'admin/approve-user'});

    final body = {
      'user_type_id': userTypeId,
      'action': action,
      if (iglooIds != null) 'igloo_ids': iglooIds,
    };

    print('\n➡️ [POST] admin/approve-user');
    print('➡️ BODY: $body');

    final (res, code) = await _api.postUri(uri, body: body);

    print('⬅️ RESPONSE CODE: $code');
    print('⬅️ RESPONSE DATA: ${res.data}\n');

    if (code == 200) {
      return const Ok(null);
    }
    return Err(_errorMessage(res), code: code);
  }

  // ---------------- ERROR HANDLER ----------------

  String _errorMessage(Response res) {
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'Request failed (${res.statusCode})';
  }
}
