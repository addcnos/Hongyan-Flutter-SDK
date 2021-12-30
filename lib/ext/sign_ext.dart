import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_im/core/im_request.dart';
import 'package:flutter_im/ext/log_ext.dart';

class SignManager {
  static final SignManager _instance = SignManager._internal();

  factory SignManager() => _instance;

  SignManager._internal();

  /// 获取签名，签名根据 请求参数、时间戳等生成 <br/>
  ///
  /// @param [url]        请求链接 <br/>
  /// @param [params]     请求参数 <br/>
  /// @param [appSecret]  应用密匙，由中台生成 <br/>
  ///
  /// @param [String]  返回签名 <br/>
  Future<Map<String, dynamic>> getSignature({
    @required String url,
    @required Map<String, dynamic> params,
    @required String appSecret,
  }) async {
    StringBuffer sb = StringBuffer();
    // 拼接请求方式
    sb.write("POST");
    // 拼接请求链接
    sb.write(url);
    // 拼接请求参数，按照ascii码表排序
    sb.write(_getSortedParams(params));
    // 拼接应用密匙
    sb.write(appSecret);
    // 拼接时间戳
    int timestamp = await _getTimestamp();
    sb.write(timestamp);
    // 拼接8位随机字符串
    String randomStr = _getRandomString(8);
    sb.write(randomStr);

    // 加密生成签名，加密方式依次为：SHA256、MD5、BASE64
    String signature = sb.toString();
    LogManager.log("signature before: $signature");
    signature = sha256.convert(utf8.encode(signature)).toString();
    signature = md5.convert(utf8.encode(signature)).toString();
    signature = base64.encode(utf8.encode(signature)).toString();
    LogManager.log("signature after: $signature");

    return {
      "_timestamp": timestamp,
      "_randomstr": randomStr,
      "_signature": signature,
    };
  }

  /// 拼接参数，按照ascii码表排序 <br/>
  ///
  /// @param [params]   请求参数 <br/>
  ///
  /// @param [String]  返回排序后的拼接参数 <br/>
  String _getSortedParams(Map<String, dynamic> params) {
    if (params == null || params.isEmpty) return "";

    StringBuffer sb = StringBuffer();
    var sortedKeys = params.keys.toList()..sort();
    sortedKeys.forEach((key) {
      if (sb.isNotEmpty) sb.write("`");
      sb.write("$key=${params[key]}");
    });
    LogManager.log("_getSortedParams: ${sb.toString()}");
    return sb.toString();
  }

  /// 获取时间戳，为了让当前客户端时间和服务器时间保持一致 <br/>
  ///
  /// @param [int]  返回时间戳 <br/>
  Future<int> _getTimestamp() async {
    int timestamp = await IMRequest.currentTimestamp();
    LogManager.log("_getTimestamp: $timestamp");
    return timestamp;
  }

  /// 生成随机字符串 <br/>
  ///
  /// @param [length]   随机字符串的长度 <br/>
  ///
  /// @param [String]  返回生成的随机字符串 <br/>
  String _getRandomString(int length) {
    String alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(alphabet[Random().nextInt(alphabet.length - 1)]);
    }
    LogManager.log("_getRandomString: ${sb.toString()}");
    return sb.toString();
  }
}
