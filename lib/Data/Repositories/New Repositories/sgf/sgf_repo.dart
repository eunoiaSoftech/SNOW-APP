// import 'package:dio/dio.dart';
// import 'package:snow_app/core/api_client.dart';
// import 'package:snow_app/Data/models/New Model/sgf_abst_model.dart';
// import 'package:snow_app/Data/models/New Model/sgf_record_model.dart';

// class ReferralsRepositorySfg {
//   final ApiClient _api = ApiClient.create();

//   /// 🧾 Fetch all SFG records
//   Future<sfgabsResponse> fetchSfgRecords({
//     bool onlyMy = false,
//     int? businessId,
//     String? startDate,
//     String? endDate,
//     String? query,
//   }) async {
//     const endpoint = '/referrals/abstract-sfg'; // ✅ correct endpoint for SFG
//     try {
//       print("🌐 GET Request → $endpoint");

//       final (res, code) = await _api.get(endpoint, query: {
//         'only_my': onlyMy, 
//         if (businessId != null) 'business_id': businessId,
//         if (startDate != null) 'start_date': startDate,
//         if (endDate != null) 'end_date': endDate,
//         if (query != null && query.isNotEmpty) 'q': query,
//       });

//       print("📥 Response Code: $code");
//       print("📦 Response Data: ${res.data}");

//       if (code == 200) {
//         return sfgabsResponse.fromJson(res.data);
//       } else {
//         throw Exception(_extractError(res));
//       }
//     } on DioException catch (e) {
//       print("❌ DioException in fetchSfgRecords: $e");
//       throw Exception("Network error: ${e.message ?? 'Unknown Dio Error'}");
//     } catch (e) {
//       print("❌ General Error in fetchSfgRecords: $e");
//       throw Exception("General error: ${e.toString()}");
//     }
//   }

//   /// 🪄 Record a new SFG (POST)
//   Future<RecordSfgPostResponse> recordSfg({
//     required String toMember,
//     required int giverBusinessId,
//     required String amount,
//     required String remarks,
//   }) async {
//     const endpoint = '/referrals/record-sfg';
//     try {
//       print("🌐 POST Request → $endpoint");

//       final body = {
//         "to_member": toMember,
//         "giver_business_id": giverBusinessId,
//         "amount": amount,
//         "remarks": remarks,
//       };

//       print("📤 Request Body: $body");

//       final (res, code) = await _api.post(endpoint, body: body);

//       print("📥 Response Code: $code");
//       print("📦 Response Data: ${res.data}");

//       if (code == 200 || code == 201) {
//         return RecordSfgPostResponse.fromJson(res.data);
//       } else {
//         throw Exception(_extractError(res));
//       }
//     } on DioException catch (e) {
//       print("❌ DioException in recordSfg: $e");
//       throw Exception("Network error: ${e.message ?? 'Unknown Dio Error'}");
//     } catch (e) {
//       print("❌ General Error in recordSfg: $e");
//       throw Exception("General error: ${e.toString()}");
//     }
//   }

//   /// 🧩 Extract error message safely
//   String _extractError(Response res) {
//     final data = res.data;
//     if (data is Map && data['message'] != null) return data['message'].toString();
//     return 'Something went wrong (${res.statusCode})';
//   }
// }
import 'package:dio/dio.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/Data/models/New Model/sgf_abst_model.dart';
import 'package:snow_app/Data/models/New Model/sgf_record_model.dart';

class ReferralsRepositorySfg {
  final ApiClient _api = ApiClient.create();

   Future<SfgAbsResponse> fetchSfgRecords({
    bool onlyMy = false,
    int? businessId,
    String? startDate,
    String? endDate,
    String? query,
  }) async {
    const endpoint = '/referrals/abstract-sfg';

    try {
      print("🚀 STEP 1: Hitting API → $endpoint");

      final (res, code) = await _api.get(endpoint, query: {
        'only_my': onlyMy.toString(),
        if (businessId != null) 'business_id': businessId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (query != null && query.isNotEmpty) 'q': query,
      });

      print("🔍 STEP 2: Response Code → $code");
      print("📦 STEP 3: Raw Response → ${res.data}");

      if (code == 200) {
        print("✅ STEP 4: Mapping JSON to SfgAbsResponse Model...");
        final parsed = SfgAbsResponse.fromJson(res.data);
        print("🎯 STEP 5: Total Records Parsed → ${parsed.records.length}");
        return parsed;
      } else {
        print("⚠️ STEP 6: API returned non-200");
        throw Exception("API error: ${res.data}");
      }
    } on DioException catch (e) {
      print("❌ DioException in fetchSfgRecords: ${e.response?.data ?? e.message}");
      throw Exception("Network error: ${e.message ?? 'Unknown Dio Error'}");
    } catch (e) {
      print("🔥 Unexpected Error at Abstract Fetch: $e");
      throw Exception("General error: ${e.toString()}");
    }
  }

  /// 🪄 Record SFG (working fine, keeping as is)
  Future<RecordSfgPostResponse> recordSfg({
    required String toMember,
    required int giverBusinessId,
    required String amount,
    required String remarks,
  }) async {
    const endpoint = '/referrals/record-sfg';
    try {
      print("🌐 POST Request → $endpoint");

      final body = {
        "to_member": toMember,
        "giver_business_id": giverBusinessId,
        "amount": amount,
        "remarks": remarks,
      };

      print("📤 Request Body: $body");

      final (res, code) = await _api.post(endpoint, body: body);

      print("📥 Response Code: $code");
      print("📦 Response Data: ${res.data}");

      if (code == 200 || code == 201) {
        return RecordSfgPostResponse.fromJson(res.data);
      } else {
        throw Exception(_extractError(res));
      }
    } on DioException catch (e) {
      print("❌ DioException in recordSfg: ${e.response?.data ?? e.message}");
      throw Exception("Network error: ${e.message ?? 'Unknown Dio Error'}");
    } catch (e) {
      print("❌ Unexpected Error in recordSfg: $e");
      throw Exception("General error: ${e.toString()}");
    }
  }

  /// 🧩 Extract API Error
  String _extractError(Response res) {
    final data = res.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return 'Something went wrong (${res.statusCode})';
  }
}
