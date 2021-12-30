import 'dart:convert';
import 'package:flutter_im/network/json/safe_convert.dart';

import '../model/message_model.dart';


typedef void NotificationCallback(Message model);

class IMMessageController {
  static final IMMessageController _instance = IMMessageController._internal();

  factory IMMessageController() => _instance;

  IMMessageController._internal();

  NotificationCallback _callback;

  Map<String, String> map = {};

  /// 接收处理消息
  void receiveMessage(String msg) {
    final data = json.decode(msg);
    Message message = parseMessageFromType(data);
    // 消息回调
    if(_callback != null) _callback(message);
  }


  /// 设置业务端在列表给的隐射
  String setContentMap(String type, Map<String, Object> json){
    switch(type){
      case MSG_TXT:
        return SafeManager.parseString(json, "content");
        break;
      case MSG_IMAGE:
        final temp = map[MSG_IMAGE];
        return temp == null ? "[圖片]" : temp;
      case MSG_CUSTOMIZE:
        final type = SafeManager.parseString(json, "customize:type");
        final temp = map[type];
        return temp == null ? "未知消息" : temp;
      default:
        final temp = map["default"];
        return temp == null ? "未知消息" : temp;
    }
  }


  /// 添加消息监听者
  void addMessageNotification({NotificationCallback callback}) => _callback = callback;
}



