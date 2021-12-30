import 'package:flutter_im/core/im_message_controller.dart';

import '../network/json/safe_convert.dart';
import 'message_model.dart';

/// ----------------------- 联系人 Model -----------------------
class Contact {
  String nickname;
  String avatar;
  int isOnline;
  String uid;
  String type;
  String lastTime;
  int newMsgCount;
  String content;

  Contact({
    this.nickname,
    this.avatar,
    this.isOnline,
    this.uid,
    this.type,
    this.content,
    this.lastTime,
    this.newMsgCount,
  });

  Contact.fromJson(Map<String, dynamic> json) {
    nickname = SafeManager.parseString(json, 'nickname');
    avatar = SafeManager.parseString(json, 'avatar');
    isOnline = SafeManager.parseInt(json, 'is_online');
    uid = SafeManager.parseString(json, 'uid');
    type = SafeManager.parseString(json, 'type');
    lastTime = SafeManager.parseString(json, 'last_time');
    newMsgCount = SafeManager.parseInt(json, 'new_msg_count');
    content = IMMessageController()
        .setContentMap(type, SafeManager.parseMap(json, 'content'));
  }

  Map<String, dynamic> toJson() => {
        'nickname': this.nickname,
        'avatar': this.avatar,
        'is_online': this.isOnline,
        'uid': this.uid,
        'type': this.type,
        'content': this.content,
        'last_time': this.lastTime,
        'new_msg_count': this.newMsgCount,
      };
}

/// ----------------------- 新消息总数 Model -----------------------
class MessageCount {
  int count;

  MessageCount({this.count});

  MessageCount.fromJson(Map<String, dynamic> json)
      : count = SafeManager.parseInt(json, 'count');

  Map<String, dynamic> toJson() => {
        'count': this.count,
      };
}

/// ----------------------- 历史消息列表 Model -----------------------
class DataList {
  List<Message> data;

  DataList({this.data});

  DataList.fromJson(Map<String, dynamic> json)
      : data = SafeManager.parseList(json, 'data')
            .reversed
            ?.map((e) => parseMessageFromType(e))
            ?.toList();

  Map<String, dynamic> toJson() => {
        'data': this.data,
      };
}

/// ----------------------- 会话中的用户信息 Model -----------------------
class ConversationInfo {
  User user;
  User target;

  ConversationInfo({this.user, this.target});

  ConversationInfo.fromJson(Map<String, dynamic> json)
      : user = User.fromJson(
          SafeManager.parseObject(json, 'user'),
        ),
        target = User.fromJson(
          SafeManager.parseObject(json, 'target'),
        );

  Map<String, dynamic> toJson() => {
        'user': this.user.toJson(),
        'target': this.target.toJson(),
      };
}

class User {
  int id = 0;
  int appId = 0;
  String uid = "";
  String nickname = "";
  String avatar = "";
  String createAt = "";
  String updateAt = "";
  String token = "";
  String extend = "";
  bool isOnline = false;

  User({
    this.id = 0,
    this.appId = 0,
    this.uid = "",
    this.nickname = "",
    this.avatar = "",
    this.createAt = "",
    this.updateAt = "",
    this.token = "",
    this.extend = "",
    this.isOnline = false,
  });

  User.fromJson(Map<String, dynamic> jsonData)
      : id = SafeManager.parseInt(jsonData, 'id'),
        appId = SafeManager.parseInt(jsonData, 'app_id'),
        uid = SafeManager.parseString(jsonData, 'uid'),
        nickname = SafeManager.parseString(jsonData, 'nickname'),
        avatar = SafeManager.parseString(jsonData, 'avatar'),
        createAt = SafeManager.parseString(jsonData, 'created_at'),
        updateAt = SafeManager.parseString(jsonData, 'updated_at'),
        token = SafeManager.parseString(jsonData, "token"),
        extend = SafeManager.parseString(jsonData, "extend"),
        isOnline = SafeManager.parseBoolean(jsonData, "is_online");

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'app_id': this.appId,
        'uid': this.uid,
        'nickname': this.nickname,
        'avatar': this.avatar,
        'created_at': this.createAt,
        'updated_at': this.updateAt,
        "token": this.token,
        "extend": this.extend,
      };
}