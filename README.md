## 数睿鸿雁SDK Flutter文档
![LICENSE](https://img.shields.io/badge/License-MIT-orange)
![Language](https://img.shields.io/badge/Language-Dart-blue.svg)
![Stable](https://img.shields.io/badge/Stable-v1.0.0-brightgreen.svg)

#### SDK概述

鸿雁即时通讯是数睿科技公司旗下的一款专注于为开发者提供实时聊天技术和服务的产品。我们的团队来自数睿科技，致力于为用户提供高效稳定的实时聊天云服务，且弹性可扩展，对外提供较为简洁的API接口，让您轻松实现快速集成即时通讯功能。

#### 环境依赖

```
sdk: ">=2.7.0 <3.0.0"
```

## 集成流程
```dart
dependencies:
  flutter:
    sdk: flutter
  
  # addcn 即时通讯
  flutter_im:
    git:
      url: https://code.addcn.com/flutter/flutter_im.git
```

#### 初始化SDK

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| token | String | 注册获取到的身份标识 | 
| appId | String | 服务器给App分配的标识 |
| appSecret | String | 服务器给App分配的标识 |
| onConnect | Function | 连接成功后回调 |
| onDisconnect | Function | 连接断开后回调 |
| autoConnect | bool | 是否自动重连 默认是 |


```dart
  /// 启动及时通讯
  ///
  /// @param [token]          用户token
  /// @param [appId]          App id，从中台获取
  /// @param [appSecret]      App secret，从中台获取
  /// @param [onConnect]      连接回调（可选） 
  /// @param [onDisconnect]   断开连接回调（可选）
  /// @param [autoConnect]    当断开连接的时候，是否自动连接，默认自动连接（可选）
  ///
  /// @param [MessageTxt]  返回相关消息信息
  void startIM({
    @required String token,
    @required String appId,
    @required String appSecret,
    WebSocketConnectCallback onConnect,
    WebSocketDisconnectCallback onDisconnect,
    bool autoConnect = true,
  }) {
    _socketUrl = ApiConfig.getWSUrl();
    _token = token;
    _appId = appId;
    _appSecret = appSecret;
    _socketUrl = "$_socketUrl?token=$token&EIO=4&transport=websocket";
    _onConnect = onConnect;
    _onDisconnect = onDisconnect;
    _autoConnect = autoConnect;
    _connect(token);
  }
```

```dart
 WebSocketManager().startIM(
        appId: imAppId,
        appSecret: imAppSecret,
        token: token,
        onConnect: (state, message) {
          LogManager.log("即时通讯连接");
        },
        onDisconnect: () {
          LogManager.log("即时通讯断开");
        },
        autoConnect: true,
      );
      // 设置消息接收器
      im.IMMessageController()
          .addMessageNotification(callback: (model) => _receiveMessage(model));
      // 设置列表特殊消息文本显示
      im.IMMessageController().map = {"work": "[作品]", "info": "[裝修訊息]"};

```

## 接口说明

#### 发送消息

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| targetUid | String | 接收者id | 
| content | String | 消息内容 |
| push | int | 是否推送 |
| device | String | 设备类型：android、ios、pc、touch（可选 |
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |

```dart
  /// 发文本消息
  ///
  /// @param [targetUid]  接收者id
  /// @param [content]    消息内容
  /// @param [push]       是否推送，0:否 1:是（可选）
  /// @param [device]     设备类型：android、ios、pc、touch（可选）
  /// @param [success]    请求成功回调（可选）
  /// @param [failed]     请求失败回调（可选）
  ///
  /// @param [MessageTxt]  返回相关消息信息 
  static Future<MessageTxt> sendTxtMessage({
    @required String targetUid,
    @required String content,
    int millisecond = 0,
    int push = -1,
    String device = "",
    IMRequestMessageSuccessCallback<Message> success,
    IMRequestMessageErrorCallback failed,
  }) async {
    return await _sendMessage<MessageTxt>(
      type: MSG_TXT,
      targetUid: targetUid,
      millisecond: millisecond,
      content: jsonEncode(MessageTxt(content: content).toContent()),
      push: push,
      device: device,
      success: success,
      failed: failed,
    );
  }
```

#### 发送图片

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| targetUid | String | 接收者id | 
| imageFile | File | 消息内容 |
| push | int | 是否推送 |
| device | String | 设备类型：android、ios、pc、touch（可选 |
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |

```dart

  /// 发图片消息 
  ///
  /// @param [targetUid]    接收者id
  /// @param [imageFile]    消息内容 
  /// @param [millisecond]  发送时间戳 
  /// @param [push]         是否推送，0:否 1:是（可选）
  /// @param [device]       设备类型：android、ios、pc、touch（可选）
  /// @param [success]      请求成功回调（可选）
  /// @param [failed]       请求失败回调（可选） 
  ///
  /// @param [MessageImage]  返回相关消息信息 
  static Future<MessageImage> sendImageMessage({
    @required String targetUid,
    @required File imageFile,
    int millisecond = 0,
    int push = -1,
    String device = "",
    IMRequestMessageSuccessCallback<MessageImage> success,
    IMRequestMessageErrorCallback failed,
    IMRequestProgressCallback progress,
  }) async {
    // 上传图片到服务器，返回上传后的大图和缩略图链接
    MessageImage messageImage = await uploadImage(
      imageFile: imageFile,
      failed: (error) => failed(error, millisecond),
      progress: progress,
    );

    if (messageImage.imgUrl.length <= 0) {
      failed("圖片上傳失敗", millisecond);
      return null;
    }
    // 将图片链接包装后发出
    return await _sendMessage<MessageImage>(
      type: MSG_IMAGE,
      targetUid: targetUid,
      millisecond: millisecond,
      content: jsonEncode(messageImage.toContent()),
      push: push,
      device: device,
      success: success,
      failed: failed,
    );
  }
```

#### 发送自定义消息

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| targetUid | String | 接收者id | 
| content | String | 消息json |
| push | int | 是否推送 |
| device | String | 设备类型：android、ios、pc、touch（可选 |
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |


```dart
  /// 发自定义消息
  ///
  /// @param [parser]     消息数据解析 
  /// @param [targetUid]  接收者id 
  /// @param [content]    消息内容 
  /// @param [push]       是否推送，0:否 1:是（可选） 
  /// @param [device]     设备类型：android、ios、pc、touch（可选）
  /// @param [success]    请求成功回调（可选）
  /// @param [failed]     请求失败回调（可选） 
  ///
  /// @param [MessageTxt]  返回消息信息 
  static Future<T> sendCustomizeMessage<T extends Message>({
    @required String targetUid,
    @required String content,
    int millisecond = 0,
    int push = -1,
    String device = "",
    IMRequestMessageSuccessCallback<T> success,
    IMRequestMessageErrorCallback failed,
  }) async {
    return await _sendMessage<T>(
      type: MSG_CUSTOMIZE,
      targetUid: targetUid,
      content: content,
      millisecond: millisecond,
      push: push,
      device: device,
      success: success,
      failed: failed,
    );
  }

```

#### 删除会话数据

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| keepDays | int | 保留的天数 | 
| keepCount | int | 保留的条数 |
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |

```dart
  /// 删除会话数据 
  ///
  /// @param [keepDays]   保留的天数  默认值: 30（可选） 
  /// @param [keepCount]  保留的条数  默认值: 100（可选） 
  /// @param [success]    请求成功回调（可选） 
  /// @param [failed]     请求失败回调（可选）
  ///
  /// @param [bool]  成功为 true，失败为 false 
  static Future<void> clearMessageSession({
    int keepDays = -1,
    int keepCount = -1,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result = false;
    var params = <String, dynamic>{"token": WebSocketManager().token};
    if (keepDays > -1) params.putIfAbsent("days", () => keepDays);
    if (keepCount > -1) params.putIfAbsent("limit", () => keepCount);
    await _post(
      Api.CLEAR_MESSAGE,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }
```

#### 消息设置已读

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| targetUid | String | 当前聊天联系人uid | 
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |

```dart
  /// 消息设置已读 
  ///
  /// @param [targetUid]  当前聊天联系人uid
  /// @param [success]    请求成功回调（可选）
  /// @param [failed]     请求失败回调（可选）
  ///
  /// @param [bool]  成功为 true，失败为 false 
  static Future<bool> markMessageAsRead({
    @required String targetUid,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result = false;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "target_uid": targetUid,
    };
    await _post(
      Api.READ_MESSAGE,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }
```

#### 聊天界面联系人列表

| 参数 | 类型 | 说明 | 
| :-----| :---- | :---- |
| limit | int | 条数 | 
| page | int | 页码 |
| success | Function | 发送成功回调 |
| failed | Function | 发送失败回调 |

```dart
  /// 聊天界面联系人列表
  ///
  /// @param [map]  映射列表 
  /// @param [limit]  每页条数  默认值: 20（可选）
  /// @param [page]   页码  默认值: 1（可选）
  /// @param [success]    请求成功回调（可选） 
  /// @param [failed]     请求失败回调（可选）
  ///
  /// @return [List<Contact>]  返回联系人列表 
  static Future<List<Contact>> getContactList({
    int limit = -1,
    int page = -1,
    IMRequestSuccessCallback<List<Contact>> success,
    IMRequestErrorCallback failed,
  }) async {
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
    };
    if (limit > -1) params.putIfAbsent("limit", () => limit);
    if (page > -1) params.putIfAbsent("page", () => page);
    var contactList = [];
    contactList = await _get<List>(
      Api.CONTACT_LIST,
      params: params,
      decoder: (json) => json.map((e) => Contact.fromJson(e)).toList(),
      success: (data) {
        if (success != null) success(data); // 这里将 dynamic 转换为 List<Contact>
      },
      failed: failed,
    ) as List<Contact>;
    return contactList;
  }

```

## 版本更新说明

#### v1.0.0
支持IM-SDK基础功能

## 相关文档

#### [数睿鸿雁SDK-flutter文档](https://github.com/addcnos/Hongyan-Flutter-SDK)
#### [数睿鸿雁SDK-Android文档](https://github.com/addcnos/Hongyan-Android-SDK)
#### [数睿鸿雁SDK-Objective-C文档](https://github.com/addcnos/Hongyan-IOS-SDK)
#### [数睿鸿雁SDK-Web文档](https://github.com/addcnos/Hongyan-Web-SDK)
