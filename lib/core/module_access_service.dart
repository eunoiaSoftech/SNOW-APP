import 'package:snow_app/Data/Models/profile_overview.dart';

class ModuleAccessService {
  ModuleAccessService._internal();

  static final ModuleAccessService _instance = ModuleAccessService._internal();

  factory ModuleAccessService() => _instance;

  List<ModuleAccess> _modules = const [];

  void updateModules(List<ModuleAccess> modules) {
    _modules = List<ModuleAccess>.from(modules);
  }

  bool hasAccess(String slug) {
    return _modules.any((module) => module.slug == slug && module.isEnabled);
  }

  List<ModuleAccess> get modules => List.unmodifiable(_modules);
}
