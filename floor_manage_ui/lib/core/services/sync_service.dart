import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class SyncService {
  final ApiService _apiService = ApiService();

  void init() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet)) {
        _syncPendingActions();
      }
    });
  }

  Future<void> _syncPendingActions() async {
    List<dynamic> actions = LocalStorageService.getPendingActions();
    if (actions.isEmpty) return;

    print('Syncing ${actions.length} pending actions...');

    List<dynamic> remainingActions = [];

    for (var action in actions) {
      try {
        if (action['method'] == 'POST') {
          dynamic data = action['data'];

          if (data is Map && data['type'] == 'upload_floor_plan') {
            String imagePath = data['image_path'];
            String fileName = imagePath.split('/').last;
            data = FormData.fromMap({
              'version': data['version'],
              'created_by': data['created_by'],
              'image': await MultipartFile.fromFile(
                imagePath,
                filename: fileName,
              ),
              'data_json': '{}',
            });
          }

          await _apiService.post(
            action['path'],
            data: data,
            enableOfflineQueue: false,
          );
        }
      } catch (e) {
        print('Sync failed for action: $action. Error: $e');
        remainingActions.add(action);
      }
    }

    if (remainingActions.length != actions.length) {
      await LocalStorageService.clearPendingActions();
      for (var action in remainingActions) {
        await LocalStorageService.addPendingAction(action);
      }
    } else {
      await LocalStorageService.clearPendingActions();
    }

    print('Sync complete.');
  }
}
