import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageRepository {
  final storage = new FlutterSecureStorage();

  Future getStoredValue(String key) async {
    try {
      String? value = await storage.read(key: key);
      return value;
    } catch (e) {
      return null;
    }
  }

  Future storeValue(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
      return;
    } catch (e) {
      return null;
    }
  }
}
