import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _boxName = 'floor_manage_box';
  static const String _pendingSyncKey = 'pending_sync_actions';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> save(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static dynamic read(String key) {
    return _box.get(key);
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> addPendingAction(Map<String, dynamic> action) async {
    List<dynamic> actions = _box.get(_pendingSyncKey, defaultValue: []);
    actions.add(action);
    await _box.put(_pendingSyncKey, actions);
  }

  static List<dynamic> getPendingActions() {
    return _box.get(_pendingSyncKey, defaultValue: []);
  }

  static Future<void> clearPendingActions() async {
    await _box.delete(_pendingSyncKey);
  }
}
