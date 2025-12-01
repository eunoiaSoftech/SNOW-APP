import 'package:snow_app/Data/models/New Model/admin_loactions_model.dart';
import 'package:snow_app/Data/models/location_option.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';

class AdminLocationRepository {
  final ApiClient _api = ApiClient.create();

  static const String _endpoint = "/";
  static const Map<String, String> _query = {
    "endpoint": "admin/location-create",
  };

  // -------------------------
  // CREATE COUNTRY
  // -------------------------
  Future<AdminCountry> createCountry(String name) async {
    try {
      final (res, code) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "country",
          "name": name,
          "code": name.substring(0, 2).toUpperCase(),
        },
      );

      if (code == 200 || code == 201) {
        return AdminCountry(id: res.data['id'], name: name);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // -------------------------
  // CREATE ZONE  (child of country)
  // -------------------------
  Future<AdminZone> createZone(String name, int countryId) async {
    try {
      final (res, code) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "zone",
          "name": name,
          "code": name.substring(0, 1).toUpperCase(),
          "parent_id": countryId,
        },
      );

      if (code == 200 || code == 201) {
        return AdminZone(id: res.data['id'], name: name, parentId: countryId);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // -------------------------
  // CREATE STATE (child of zone)
  // -------------------------
  Future<AdminState> createState(String name, int zoneId) async {
    try {
      final (res, code) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "state",
          "name": name,
          "code": name.substring(0, 1).toUpperCase(),
          "parent_id": zoneId,
        },
      );

      if (code == 200 || code == 201) {
        return AdminState(id: res.data['id'], name: name, countryId: zoneId);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // -------------------------
  // CREATE CITY (child of state)
  // -------------------------
  Future<AdminCity> createCity(String name, int stateId) async {
    try {
      final (res, code) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "city",
          "name": name,
          "code": name.substring(0, 2).toUpperCase(),
          "parent_id": stateId,
        },
      );

      if (code == 200 || code == 201) {
        return AdminCity(
          id: res.data['id'],
          name: name,
          countryId: 0,
          stateId: stateId,
        );
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // -------------------------
  // DELETE ANY LOCATION
  // -------------------------
  Future<bool> deleteLocation(int id) async {
    try {
      final query = {
        "endpoint": "admin/location-delete",
        "id": id.toString()
      };

      final (res, code) = await _api.delete(_endpoint, query: query);

      if (code == 200) return true;

      throw Exception("Delete Failed: ${res.data}");
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }



}
