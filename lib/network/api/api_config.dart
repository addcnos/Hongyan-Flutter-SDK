import 'package:flutter_im/constant/Constants.dart';

import 'api.dart';

class ApiConfig {
  static bool isDebug = false;

  static String getWSUrl() {
    if (isDebug) return Api.SOCKET_DEBUG;
    return Api.SOCKET_RELEASE;
  }

  static String getIMUrl() {
    if (isDebug) return Api.DEBUG;
    return Api.RELEASE;
  }

  static String get100Url() {
    if (isDebug) return Api.DEBUG100;
    return Api.RELEASE100;
  }
}
