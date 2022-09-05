import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hongyan_im/flutter_im.dart';
import 'package:hongyan_im/network/json/safe_convert.dart';

void main() {
  const String uid_1 = "1903175";
  const String token1 = "4e85075565ea24ed4193b23fc331aae56ea78be6";
  const String uid_2 = "1637";
  const String token2 = "cd441d49863e024daa7cd14c7862454b5b2d2739";
  const String appIdAndroid = "dpcDaNaqPbdd";
  const String appSecretAndroid = "5p7e8ebacd6qpd65f3ce9d654209hewa";
  const String appIdiOS = "yeaPaqbf";
  const String appSecretiOS = "689a63e778c5a234e6r25ae3werb8tac";

  setUp(() {
    WebSocketManager()
        .setupTokenForTest(token1, appIdAndroid, appSecretAndroid);
  });

  test('clearMessageSession', () async {
    await IMRequest.clearMessageSession(
      success: (data) {
        print("clearMessageSession: $data");
      },
    );
  });

  test('markMessageAsRead', () async {
    await IMRequest.markMessageAsRead(
      targetUid: uid_1,
      success: (data) {
        print("markMessageAsRead: $data");
      },
    );
  });

  test('getContactList', () async {
    await IMRequest.getContactList(
      success: (data) {
        print("getContactList: $data");
        data.forEach((element) {
          print(element.toJson());
        });
      },
    );
  });

  test('getConversationInfo', () async {
    await IMRequest.getConversationInfo(
      targetUid: uid_2,
      success: (data) {
        print("getConversationInfo: ${data.toJson()}");
        UserExtend extend = UserExtend.fromJson(json.decode(data.user.extend));
        print("getConversationInfo: ${extend.toJson()}");
        print("getConversationInfo role: ${extend.role}");
      },
    );
  });

  test('getNewMessageCount', () async {
    await IMRequest.getNewMessageCount(
      success: (data) {
        print("getNewMessageCount: $data");
      },
    );
  });

  test('onlineNotice', () async {
    await IMRequest.onlineNotice(
      success: (data) {
        print("onlineNotice: $data");
      },
    );
  });

  test('deleteContact', () async {
    await IMRequest.deleteContact(
      targetUid: uid_2,
      success: (data) {
        print("deleteContact: $data");
      },
    );
  });

  test('markMessageArrived', () async {
    await IMRequest.markMessageArrived(
      msgId: "01001",
      success: (data) {
        print("markMessageArrived: $data");
      },
    );
  });

  test('sendTxtMessage', () async {
    await IMRequest.sendTxtMessage(
      targetUid: uid_2,
      device: "android",
      content: "s涉及到合格",
      success: (data, timer) {
        print("sendTxtMessage: ${data.toJson()}");
      },
    );
  });

  test('sendImageMessage', () async {
    await IMRequest.sendImageMessage(
      targetUid: uid_2,
      imageFile: File("assets/test.jpg"),
      success: (data, timer) {
        print("sendTxtMessage: ${data.toJson()}");
      },
    );
  });

  test('sendCustomizeMessage', () async {
    MessageWorks messageWorks = MessageWorks(
      worksId: "10001",
      title: "title",
      content: "content",
    );
    await IMRequest.sendCustomizeMessage<MessageWorks>(
      //parser: (json) => MessageWorks.formJson(json),
      targetUid: uid_2,
      content: jsonEncode(messageWorks.toContent()),
      success: (data, timer) {
        print("sendCustomizeMessage: ${data.toJson()}");
      },
    );
  });

  test('uploadImage', () async {
    await IMRequest.uploadImage(
      imageFile: File("assets/test.jpg"),
      success: (data) {
        print("markMessageArrived: $data");
      },
      progress: (count, total) {
        print("count: $count  total: $total   "
            "percent: ${(count / total * 100).toString().split(".")[0]}%");
      },
    );
  });

  test('syncMessage', () async {
    await IMRequest.syncMessage(
      fromUid: uid_2,
      success: (data) {
        print("syncMessage: $data");
      },
    );
  });

  test('getHistoryMessage', () async {
    await IMRequest.getHistoryMessage(
      linkUser: uid_2,
      success: (data) {
        print("getHistoryMessage: $data");
        data.forEach((element) {
          print(element.toJson());
        });
      },
    );
  });

  test('currentTimestamp', () async {
    await IMRequest.currentTimestamp(
      success: (timestamp) {
        print("currentTimestamp: $timestamp");
      },
    );
  });

  test('testList', () {
    List<Message> list = [];
    list.add(MessageTxt(content: "txt"));
    list.add(MessageImage(imgUrl: "imgUrl", thumbnailUrl: "imgUrl"));
    list.forEach((element) {
      if (element is MessageTxt) print(element.content);
      if (element is MessageImage) print(element.imgUrl);
    });
  });
}

class MessageWorks extends Message {
  String worksId;
  String title;
  String content;

  MessageWorks({this.worksId, this.title, this.content}) : super();

  MessageWorks.formJson(Map<String, dynamic> json) {
    this.fromJson(json);
    final data = SafeManager.parseMap(json, "content");
    worksId = SafeManager.parseString(data, "works_id");
    title = SafeManager.parseString(data, "title");
    content = SafeManager.parseString(data, "content");
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map.putIfAbsent('content', () => toContent());
    return map;
  }

  Map<String, dynamic> toContent() => {
        'works_id': this.worksId,
        'title': this.title,
        'content': this.content,
      };
}

class UserExtend {
  String userId;
  String companyId;
  String contact;
  String role;

  UserExtend({
    this.userId,
    this.companyId,
    this.contact,
    this.role,
  });

  UserExtend.fromJson(Map<String, dynamic> jsonData)
      : companyId = SafeManager.parseString(jsonData, 'company_id'),
        userId = SafeManager.parseString(jsonData, 'user_id'),
        contact = SafeManager.parseString(jsonData, 'contact'),
        role = SafeManager.parseString(jsonData, 'role');

  Map<String, dynamic> toJson() => {
        'company_id': this.companyId,
        'user_id': this.userId,
        'contact': this.contact,
        'role': this.role,
      };
}
