import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:hongyan_im/ext/log_ext.dart';
import 'package:hongyan_im/ext/sign_ext.dart';
import 'package:hongyan_im/network/api/api_config.dart';
import 'package:hongyan_im/network/json/safe_convert.dart';

import '../core/web_socket_client.dart';
import '../model/im_request_model.dart';
import '../model/message_model.dart';
import '../network/api/api.dart';
import '../network/api/http_request.dart';
import '../network/json/response.dart';

typedef IMRequestSuccessCallback<T> = void Function(T data);
typedef IMRequestErrorCallback = void Function(String error);
typedef IMRequestMessageSuccessCallback<T> = void Function(
    T data, int millisecond);
typedef IMRequestMessageErrorCallback = void Function(
    String error, int millisecond);
typedef IMRequestProgressCallback = void Function(int count, int total);

class IMRequest {
  /// 删除会话数据 <br/>
  ///
  /// @param [keepDays]   保留的天数  默认值: 30（可选） <br/>
  /// @param [keepCount]  保留的条数  默认值: 100（可选） <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
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

  /// 消息设置已读 <br/>
  ///
  /// @param [targetUid]  当前聊天联系人uid <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
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

  /// 聊天界面联系人列表 <br/>
  ///
  /// @param [map]  映射列表  <br/>
  /// @param [limit]  每页条数  默认值: 20（可选） <br/>
  /// @param [page]   页码  默认值: 1（可选） <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @return [List<Contact>]  返回联系人列表 <br/>
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

  /// 获取会话双方信息 <br/>
  ///
  /// @param [targetUid]  目标用户：当前会话中的对方 <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @return [ConversationInfo]  会话双方信息 <br/>
  static Future<ConversationInfo> getConversationInfo({
    @required String targetUid,
    IMRequestSuccessCallback<ConversationInfo> success,
    IMRequestErrorCallback failed,
  }) async {
    var result;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "target_uid": targetUid,
    };
    await _get(
      Api.CONVERSATION_INFO,
      params: params,
      decoder: (json) => ConversationInfo.fromJson(json),
      success: (data) {
        var result = (data as ConversationInfo);
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }

  /// 获取新消息总数 <br/>
  ///
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @return [int]  新消息的数量，返回 -1 表示请求失败 <br/>
  static Future<int> getNewMessageCount({
    IMRequestSuccessCallback<int> success,
    IMRequestErrorCallback failed,
  }) async {
    var result = -1;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
    };
    await _get(
      Api.NEW_MESSAGE_COUNT,
      params: params,
      decoder: (json) => MessageCount.fromJson(json),
      success: (data) {
        int count = (data as MessageCount).count;
        if (success != null) success(count);
        result = count;
      },
      failed: failed,
    );
    return result;
  }

  /// 上线广播 <br/>
  ///
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
  static Future<bool> onlineNotice({
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result = false;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
    };
    await _post(
      Api.ONLINE_NOTICE,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }

  /// 删除联络人 <br/>
  ///
  /// @param [targetUid]  被删者uid <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
  static Future<bool> deleteContact({
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
      Api.DELETE_CONTACT,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }

  /// 消息设置已读 <br/>
  ///
  /// @param [msgId]    消息id <br/>
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
  static Future<bool> markMessageArrived({
    @required String msgId,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result = false;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "msg_id": msgId,
    };
    await _post(
      Api.MESSAGE_ARRIVAL,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }

  /// 发消息 <br/>
  ///
  /// @param [type]           消息类型 <br/>
  /// @param [parser]         消息数据解析 <br/>
  /// @param [targetUid]      接收者id <br/>
  /// @param [content]        消息内容 <br/>
  /// @param [push]           是否推送，0:否 1:是（可选） <br/>
  /// @param [device]         设备类型：android、ios、pc、touch（可选） <br/>
  /// @param [needSignature]  是否需要验签，默认为 是（可选） <br/>
  /// @param [success]        请求成功回调（可选） <br/>
  /// @param [failed]         请求失败回调（可选） <br/>
  ///
  /// @param [Message]  返回相关消息信息 <br/>
  static Future<T> _sendMessage<T extends Message>({
    @required String type,
    @required String targetUid,
    @required String content,
    int millisecond = 0,
    int push = -1,
    String device = "",
    bool needSignature = true,
    IMRequestMessageSuccessCallback<T> success,
    IMRequestMessageErrorCallback failed,
  }) async {
    var result;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "type": type,
      "target_uid": targetUid,
      "content": content,
    };
    if (push != -1) params.putIfAbsent("push", () => push);
    String platform =
        device.isEmpty ? (Platform.isAndroid ? "android" : "ios") : device;
    params.putIfAbsent("device", () => platform);
    if (needSignature) {
      var url = ApiConfig.getIMUrl().split("://")[1];
      var mapParams = await SignManager().getSignature(
        url: url + Api.SEND_MESSAGE,
        params: params,
        appSecret: WebSocketManager().appSecret,
      );
      params.addAll(mapParams);
      params.putIfAbsent("_appid", () => WebSocketManager().appId);
    }
    LogManager.log("${params.toString()}");
    await _post(
      Api.SEND_MESSAGE,
      decoder: (json) => parseMessageFromType(json),
      params: params,
      success: (data) {
        result = (data as T);
        if (success != null) success(result, millisecond);
      },
      failed: (error) => failed(error, millisecond),
    );
    return result;
  }

  /// 发文本消息 <br/>
  ///
  /// @param [targetUid]  接收者id <br/>
  /// @param [content]    消息内容 <br/>
  /// @param [push]       是否推送，0:否 1:是（可选） <br/>
  /// @param [device]     设备类型：android、ios、pc、touch（可选） <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [MessageTxt]  返回相关消息信息 <br/>
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

  /// 发图片消息 <br/>
  ///
  /// @param [targetUid]    接收者id <br/>
  /// @param [imageFile]    消息内容 <br/>
  /// @param [millisecond]  发送时间戳 <br/>
  /// @param [push]         是否推送，0:否 1:是（可选） <br/>
  /// @param [device]       设备类型：android、ios、pc、touch（可选） <br/>
  /// @param [success]      请求成功回调（可选） <br/>
  /// @param [failed]       请求失败回调（可选） <br/>
  ///
  /// @param [MessageImage]  返回相关消息信息 <br/>
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

  /// 发自定义消息 <br/>
  ///
  /// @param [parser]     消息数据解析 <br/>
  /// @param [targetUid]  接收者id <br/>
  /// @param [content]    消息内容 <br/>
  /// @param [push]       是否推送，0:否 1:是（可选） <br/>
  /// @param [device]     设备类型：android、ios、pc、touch（可选） <br/>
  /// @param [success]    请求成功回调（可选） <br/>
  /// @param [failed]     请求失败回调（可选） <br/>
  ///
  /// @param [MessageTxt]  返回消息信息 <br/>
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

  /// 图片上传 <br/>
  ///
  /// @param [picture]  图片文件 file <br/>
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  /// @param [progress] 上传进度回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
  static Future<MessageImage> uploadImage({
    @required File imageFile,
    IMRequestSuccessCallback<MessageImage> success,
    IMRequestErrorCallback failed,
    IMRequestProgressCallback progress,
  }) async {
    var result;
    dio.MultipartFile image = await dio.MultipartFile.fromFile(
      imageFile.path,
      filename: "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await HttpRequest().postUpload(
      Api.UPLOAD_IMAGE,
      formData: {"token": WebSocketManager().token, "picture": image},
      callBack: (data) {
        Response.fromJson(
          data, // 数据
          (json) => MessageImage.fromContent(json), // 对解析出来的data数据进行解析
          (message, data) {
            result = data as MessageImage;
            // code 返回 200
            if (success != null) success(result);
          },
          failed, // code 返回 非200
        );
      },
      errorCallBack: (error) {
        if (failed != null) failed(error.message);
      },
      progressCallBack: progress,
    );
    return result;
  }

  /// 消息同步 <br/>
  ///
  /// @param [token]    同步目标：同步到用户的token <br/>
  /// @param [fromUid]  同步来源：被同步者uid <br/>
  /// @param [limit]    同步的天数，默认值: 365（可选） <br/>
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  ///
  /// @param [bool]  成功为 true，失败为 false <br/>
  static Future<bool> syncMessage({
    @required String fromUid,
    int limit = -1,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result = false;
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "from_uid": fromUid,
    };
    if (limit != -1) params.putIfAbsent("limit", () => limit);
    await _post(
      Api.SYNC_MESSAGE,
      params: params,
      success: (data) {
        result = true;
        if (success != null) success(result);
      },
      failed: failed,
    );
    return result;
  }

  /// 获取历史消息 <br/>
  ///
  /// @param [linkUser]   聊天对象 <br/>
  /// @param [modeMarker] 查询标记（可选） <br/>
  /// @param [limit]      每次拉取条数  默认值: 10（可选） <br/>
  ///
  /// @return [List<Message>]  返回联系人列表 <br/>
  static Future<List<Message>> getHistoryMessage({
    @required String linkUser,
    String modeMarker = "",
    String limit = "",
    IMRequestSuccessCallback<List<Message>> success,
    IMRequestErrorCallback failed,
  }) async {
    var messageList = [];
    var params = <String, dynamic>{
      "token": WebSocketManager().token,
      "link_user": linkUser
    };
    if (modeMarker.isNotEmpty)
      params.putIfAbsent("node_marker", () => modeMarker);
    if (limit.isNotEmpty) params.putIfAbsent("limit", () => limit);
    await _get(
      Api.HISTORY_MESSAGE,
      params: params,
      decoder: (json) => DataList.fromJson(json),
      success: (data) {
        messageList = (data as DataList).data;
        if (success != null)
          success(messageList); // 这里将 dynamic 转换为 List<Contact>
      },
      failed: failed,
    );
    return messageList;
  }

  /// 获取当前时间戳 <br/>
  ///
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  ///
  /// @return [int]  返回当前时间戳 <br/>
  static Future<int> currentTimestamp({
    IMRequestSuccessCallback<int> success,
    IMRequestErrorCallback failed,
  }) async {
    int timestamp = 0;
    await _get(
      Api.CURRENT_TIMESTAMP,
      success: (data) {
        var dataMap = SafeManager.parseMap(data, "data");
        timestamp = SafeManager.parseInt(dataMap, "_timestamp");
        LogManager.log("结果: $timestamp");
        if (success != null) success(timestamp);
      },
      failed: failed,
    );
    return timestamp;
  }

  /// post请求封装 <br/>
  ///
  /// @param [url]      请求链接 <br/>
  /// @param [params]   请求参数（可选） <br/>
  /// @param [decoder]  json数据解析器，用于解析 data 下的数据（可选） <br/>
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  static Future<void> _post<T>(
    String url, {
    Map<String, dynamic> params,
    Function(T) decoder,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result;
    await HttpRequest().post(
      url,
      params: params,
      callBack: (data) {
        Response.fromJson(
          data, // 数据
          decoder ?? (json) => data, // 对解析出来的data数据进行解析
          (message, data) {
            // code 返回 200
            if (success != null) success(data);
            result = data;
          },
          failed, // code 返回 非200
        );
      },
      errorCallBack: (error) {
        if (failed != null) failed(error.message);
      },
    );
    return result;
  }

  /// get请求封装 <br/>
  ///
  /// @param [url]      请求链接 <br/>
  /// @param [params]   请求参数（可选） <br/>
  /// @param [decoder]  json数据解析器，用于解析 data 下的数据（可选） <br/>
  /// @param [success]  请求成功回调（可选） <br/>
  /// @param [failed]   请求失败回调（可选） <br/>
  static Future<dynamic> _get<T>(
    String url, {
    Map<String, dynamic> params,
    Function(T) decoder,
    IMRequestSuccessCallback success,
    IMRequestErrorCallback failed,
  }) async {
    var result;
    await HttpRequest().get(
      url,
      params: params,
      callBack: (data) {
        Response<T>.fromJson(
          data, // 数据
          decoder ?? (json) => data, // 对解析出来的data数据进行解析
          (message, data) {
            // code 返回 200
            if (success != null) success(data);
            result = data;
          },
          failed, // code 返回 非200
        );
      },
      errorCallBack: (error) {
        if (failed != null) failed(error.message);
      },
    );
    return result;
  }
}
