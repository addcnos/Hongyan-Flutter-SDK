import 'dart:io';

import '../network/json/safe_convert.dart';

const String MSG_TXT = "Msg:Txt";
const String MSG_IMAGE = "Msg:Img";
const String MSG_CUSTOMIZE = "Msg:Customize";

enum MessageType { TXT, IMAGE, CUSTOMIZE }


/// 解析器
Message parseMessageFromType(Map<String, dynamic> json) {
  final type = SafeManager.parseString(json, 'type');
  switch (type) {
    case MSG_TXT:
      return MessageTxt.formJson(json);
    case MSG_IMAGE:
      return MessageImage.formJson(json);
    case MSG_CUSTOMIZE:
      return MessageCustomize.formJson(json);
    default:
      return Message.fromJson(json);
  }
}

/// 消息基类
class Message {
  String id = "";
  String type = ""; // 消息类型
  String msgId = ""; // 消息uid
  String fromUid = ""; // 接受者id
  String targetUid = ""; // 发送者id
  String sendTime = ""; // 发送时间
  String createAt = ""; // 创建时间
  String status = ""; // 在线状态
  int needArrivalCallback = 1; // 消息是否需要回传, 0:否 1:是
  int messageDirection = 1; // 1: 自己发出的消息, 2: 接收的消息
  int sendState = 0; // 发送状态 0:正在发生， 1: 发生成功， 其他发生失败
  int uploadTime = 0; // 本地发送时间 用来匹配本地消息
  Map<String, Object> rawData; // 原始数据
  bool isRead = false; // 是否读取
  String conversation = ""; // 会话标识

  Message({
    this.id = "",
    this.msgId = "",
    this.fromUid = "",
    this.targetUid = "",
    this.type = "",
    this.sendTime = "",
    this.status = "",
    this.createAt = "",
    this.needArrivalCallback = 1,
    this.messageDirection = 1,
    this.sendState = 0,
    this.uploadTime = 0,
    this.rawData,
    this.isRead = false,
    this.conversation = "",
  });

  Message.fromJson(Map<String, dynamic> json){
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    id = SafeManager.parseString(json, 'id');
    msgId = SafeManager.parseString(json, 'msg_id');
    fromUid = SafeManager.parseString(json, 'from_uid');
    targetUid = SafeManager.parseString(json, 'target_uid');
    type = SafeManager.parseString(json, 'type');
    sendTime = SafeManager.parseString(json, 'send_time');
    status = SafeManager.parseString(json, 'status');
    createAt = SafeManager.parseString(json, 'created_at');
    needArrivalCallback = SafeManager.parseInt(json, 'arrivals_callback');
    messageDirection = SafeManager.parseInt(json, 'message_direction');
    isRead = SafeManager.parseBoolean(json, "read");
    conversation = SafeManager.parseString(json, "conversation");
    rawData = json;
    sendState = 1;
  }

  void copy(Message message){
    id = message.id;
    type = message.type;
    msgId = message.msgId;
    fromUid = message.fromUid;
    targetUid = message.targetUid;
    sendTime = message.sendTime;
    createAt = message.createAt;
    status = message.status;
    needArrivalCallback = message.needArrivalCallback;
    messageDirection = message.messageDirection;
    sendState = 1;
  }

  Map<String, Object> toJson() => {
    'id': id,
    'msg_id': msgId,
    'from_uid': fromUid,
    'target_uid': targetUid,
    'type': type,
    'send_time': sendTime,
    'status': status,
    'created_at': createAt,
    'arrivals_callback': needArrivalCallback,
    'message_direction': messageDirection,
    "sendState": sendState,
    "rawData": rawData,
    "uploadTime": uploadTime,
  };
}

/// 文本消息
class MessageTxt extends Message {
  String content = "";
  String extra = "";
  MessageTxt({this.content = "", this.extra = ""}) : super();

  MessageTxt.formJson(Map<String, dynamic> json) {
    this.fromJson(json);
    final data = SafeManager.parseMap(json, "content");
    content = SafeManager.parseString(data, "content");
    extra = SafeManager.parseString(data, "extra");
  }

  MessageTxt.devSend({String content = ""}){
    this.type = MSG_TXT;
    this.content = content;
    this.sendState = 0;
    this.uploadTime = DateTime.now().millisecondsSinceEpoch;
    this.messageDirection = 1;
  }

  @override
  void copy(Message message){
    super.copy(message);
    if(message is MessageTxt){
      content = message.content;
      extra = message.extra;
    }
  }

  Map<String, Object> toJson() {
    Map<String, Object> map = super.toJson();
    map.putIfAbsent('content', () => toContent());
    return map;
  }

  Map<String, dynamic> toContent() => {
    'content': content,
    'extra': extra,
  };
}

/// 图片消息
class MessageImage extends Message {
  String imgUrl = "";
  String thumbnailUrl = "";
  File imageFile;

  MessageImage({this.imgUrl = "", this.thumbnailUrl = ""}) : super();

  MessageImage.formJson(Map<String, dynamic> json) {
    this.fromJson(json);
    final data = SafeManager.parseMap(json, "content");
    imgUrl = SafeManager.parseString(data, "img_url");
    thumbnailUrl = SafeManager.parseString(data, "thumbnail_url");
  }

  MessageImage.devSend({File imageFile}){
    this.type = MSG_IMAGE;
    this.imageFile = imageFile;
    this.sendState = 0;
    this.uploadTime = DateTime.now().millisecondsSinceEpoch;
    this.messageDirection = 1;
  }

  @override
  void copy(Message message){
    super.copy(message);
    if(message is MessageImage){
      imgUrl = message.imgUrl;
      thumbnailUrl = message.thumbnailUrl;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map.putIfAbsent('content', () => toContent());
    return map;
  }

  MessageImage.fromContent(Map<String, dynamic> json)
      : imgUrl = SafeManager.parseString(json, 'img_url'),
        thumbnailUrl = SafeManager.parseString(json, 'thumbnail_url');

  Map<String, dynamic> toContent() => {
    'img_url': this.imgUrl,
    'thumbnail_url': this.thumbnailUrl,
    'extra': '',
  };
}

/// 自定义消息 需要继承该类使用
class MessageCustomize extends Message {
  Object customize;
  MessageCustomize({this.customize});
  MessageCustomize.formJson(Map<String, dynamic> json) {
    this.fromJson(json);
  }
}

