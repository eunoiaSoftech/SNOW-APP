import 'package:snow_app/Data/models/New Model/admin_loactions_model.dart';
import 'package:snow_app/core/api_client.dart';

class AdminLocationRepository {
  final ApiClient _api = ApiClient.create();

  static const String _endpoint = "/";
  static const Map<String, String> _query = {
    "endpoint": "admin/location-create",
  };

  static int _parseNewId(dynamic responseBody) {
    if (responseBody is! Map) return 0;
    final m = Map<String, dynamic>.from(responseBody);
    final nested = m['data'];
    final raw = m['id'] ?? (nested is Map ? nested['id'] : null);
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  static String _countryCode(String name, String? explicit) {
    final e = explicit?.trim();
    if (e != null && e.isNotEmpty) return e.toUpperCase();
    final n = name.trim();
    if (n.length >= 2) return n.substring(0, 2).toUpperCase();
    return n.isEmpty ? 'XX' : '${n[0].toUpperCase()}X';
  }

  static String _zoneOrStateCode(String name, String? explicit) {
    final e = explicit?.trim();
    if (e != null && e.isNotEmpty) return e.toUpperCase();
    final n = name.trim();
    if (n.isEmpty) return 'X';
    return n[0].toUpperCase();
  }

  static String _cityCode(String name, String? explicit) {
    final e = explicit?.trim();
    if (e != null && e.isNotEmpty) return e.toUpperCase();
    final n = name.trim();
    if (n.length >= 2) return n.substring(0, 2).toUpperCase();
    return n.isEmpty ? 'XX' : '${n[0].toUpperCase()}X';
  }

  // -------------------------
  // CREATE COUNTRY
  // -------------------------
  Future<AdminCountry> createCountry(String name, {String? locationCode}) async {
    try {
      final (res, statusCode) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "country",
          "name": name,
          "code": _countryCode(name, locationCode),
        },
      );

      if (statusCode == 200 || statusCode == 201) {
        final id = _parseNewId(res.data);
        if (id == 0) throw Exception("Error: missing id in ${res.data}");
        return AdminCountry(id: id, name: name);
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
  Future<AdminZone> createZone(
      String name,
      int countryId, {
        String? locationCode,
      }) async {
    try {
      final (res, statusCode) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "zone",
          "name": name,
          "code": _zoneOrStateCode(name, locationCode),
          "parent_id": countryId,
        },
      );

      if (statusCode == 200 || statusCode == 201) {
        final id = _parseNewId(res.data);
        if (id == 0) throw Exception("Error: missing id in ${res.data}");
        return AdminZone(id: id, name: name, parentId: countryId);
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
  Future<AdminState> createState(
      String name,
      int zoneId, {
        String? locationCode,
      }) async {
    try {
      final (res, statusCode) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "state",
          "name": name,
          "code": _zoneOrStateCode(name, locationCode),
          "parent_id": zoneId,
        },
      );

      if (statusCode == 200 || statusCode == 201) {
        final id = _parseNewId(res.data);
        if (id == 0) throw Exception("Error: missing id in ${res.data}");
        return AdminState(id: id, name: name, countryId: zoneId);
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
  Future<AdminCity> createCity(
      String name,
      int stateId, {
        String? locationCode,
      }) async {
    try {
      final (res, statusCode) = await _api.post(
        _endpoint,
        query: _query,
        body: {
          "type": "city",
          "name": name,
          "code": _cityCode(name, locationCode),
          "parent_id": stateId,
        },
      );

      if (statusCode == 200 || statusCode == 201) {
        final id = _parseNewId(res.data);
        if (id == 0) throw Exception("Error: missing id in ${res.data}");
        return AdminCity(
          id: id,
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

      final (res, statusCode) = await _api.delete(_endpoint, query: query);

      if (statusCode == 200) return true;

      throw Exception("Delete Failed: ${res.data}");
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }



}
