import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_im/network/api/api_config.dart';

class HeaderInterceptor extends InterceptorsWrapper {
  /// 获取网络请求URL <br/>
  static Future<String> getBaseUrl() async {
    return ApiConfig.getIMUrl();
  }

  /// 添加Header拦截器 <br/>
  addHeaderInterceptors(RequestOptions options) async {
    options.headers["Accept"] = "application/json";
    options.headers["Charset"] = "UTF-8";
    options.headers["Connection"] = "Keep-Alive";
    options.headers["Encoding"] = "UTF-8";
    options.headers["Accept"] = "application/vnd.100design.v2+json; image/webp";
  }

  @override
  Future onRequest(RequestOptions options) async {
    String url = await getBaseUrl();
    options.baseUrl = url;
    addHeaderInterceptors(options);
    return options;
  }
}
