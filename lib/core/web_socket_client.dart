import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_im/ext/log_ext.dart';
import 'package:flutter_im/network/api/api_config.dart';
import 'package:web_socket_channel/io.dart';

import '../core/im_message_controller.dart';
import '../network/json/safe_convert.dart';

typedef WebSocketConnectCallback = Function(bool result, String message);
typedef WebSocketDisconnectCallback = Function();

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  /// 连接成功
  final connectSuccess = "Sys:Connect";

  /// 连接失败
  final connectFailure = "Sys:Disconnect";

  IOWebSocketChannel _channel;
  String _token = "";
  String _appId = "";
  String _appSecret = "";
  String _socketUrl = ApiConfig.getWSUrl();
  WebSocketConnectCallback _onConnect;
  WebSocketDisconnectCallback _onDisconnect;
  bool _autoConnect = true;
  Timer _heartbeatTimer;
  Timer _reconnectTimer;
  bool _isClose = false;

  String get token => _token;

  String get appId => _appId;

  String get appSecret => _appSecret;

  /// 启动及时通讯 <br/>
  ///
  /// @param [token]          用户token <br/>
  /// @param [appId]          App id，从中台获取 <br/>
  /// @param [appSecret]      App secret，从中台获取 <br/>
  /// @param [onConnect]      连接回调（可选） <br/>
  /// @param [onDisconnect]   断开连接回调（可选） <br/>
  /// @param [autoConnect]    当断开连接的时候，是否自动连接，默认自动连接（可选） <br/>
  ///
  /// @param [MessageTxt]  返回相关消息信息 <br/>
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

  /// 关闭
  void close() {
    LogManager.log("-----im---- 关闭连接");
    _isClose = true;
    _cleanTimer();
    _cleanConnect();
  }

  /// 连接
  void _connect(String token) {
    _cleanTimer();
    _cleanConnect();
    _channel = new IOWebSocketChannel.connect(_socketUrl);
    LogManager.log("-----im---- 开始连接- $_socketUrl");
    _channel.stream.listen(
      (message) => _receiveMessage(message),
      onDone: () {
        _cleanTimer();
        LogManager.log("-----im---- 断开连接");
        if (_onDisconnect != null) _onDisconnect();
        if (_autoConnect && !_isClose && _reconnectTimer == null) {
          LogManager.log("-----im---- 断线开始重连");
          _reconnect();
        } else {
          if (_isClose) LogManager.log("-----im---- 主動斷開");
        }
      },
    );
  }

  void _cleanTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cleanConnect() {
    _channel?.sink?.close();
    _channel = null;
  }

  /// 获取消息类型
  String _getMessageType(String message) {
    final data = json.decode(message);
    return SafeManager.parseString(data, "type");
  }

  /// 获取系统消息提示
  String _getMessageSysNotice(String message) {
    final data = json.decode(message);
    final content = SafeManager.parseMap(data, "content");
    return SafeManager.parseString(content, "msg");
  }

  /// 消息处理
  void _receiveMessage(String message) {
    print("接收到消息： $message");
    final messageType = _getMessageType(message);
    if (messageType.startsWith("Sys:")) {
      // 系统消息
      if (messageType == connectSuccess) {
        LogManager.log("-----im---- 连接成功");
        // 连接成功
        _isClose = false;
        _sendHeartbeat();
        _reconnectTimer?.cancel();
        _reconnectTimer = null;

        if (_onConnect != null) _onConnect(true, _getMessageSysNotice(message));
      } else if (messageType == connectFailure) {
        LogManager.log("-----im---- 连接失败");
        // 连接失败
        if (_onConnect != null)
          _onConnect(false, _getMessageSysNotice(message));
      } else {
        LogManager.log("-----im---- 收到已读消息");
        // 其他系统消息
        if (messageType == "Sys:MsgReaded") {
          // 读取通知
          IMMessageController().receiveMessage(message);
        }
      }
    } else if (messageType.startsWith("Ntf")) {
      // 上线 下线通知
      if (messageType == "Ntf:Online") {
        LogManager.log("-----im---- 收到上线通知");
        IMMessageController().receiveMessage(message);
      } else if (messageType == "Ntf:Offline") {
        LogManager.log("-----im---- 收到下线通知");
        IMMessageController().receiveMessage(message);
      }
    } else {
      // 聊天消息
      IMMessageController().receiveMessage(message);
    }
  }

  /// 发送心跳包
  void _sendHeartbeat() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    LogManager.log("-----im----  创建定时器发送心跳包");
    _heartbeatTimer =
        Timer.periodic(Duration(milliseconds: 1000 * 30), (timer) {
      LogManager.log("-----im----  每隔30秒发送心跳包");
      _channel.sink.add("heartbeat");
    });
  }

  /// 断线重连
  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    LogManager.log("-----im----  创建定时器重连");
    _reconnectTimer = Timer.periodic(Duration(milliseconds: 1000 * 3), (timer) {
      print("-----im---- 每隔3秒重新连接webSocket");
      _connect(_token);
    });
  }

  /// 该函数只能用于测试使用
  @visibleForTesting
  void setupTokenForTest(String token, String appId, String appSecret) {
    this._token = token;
    this._appId = appId;
    this._appSecret = appSecret;
  }
}
