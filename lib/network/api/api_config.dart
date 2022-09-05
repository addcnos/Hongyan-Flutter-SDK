
import 'api.dart';

class ApiConfig {
  static bool isDebug = false;

  static String getWSUrl() => Api.dns;

  static String getIMUrl() => Api.api;
}
