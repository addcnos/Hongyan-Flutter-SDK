/// 接口类
class Api {
  /// 正式环境
  static const String RELEASE = "https://im.100.com.tw/";

  /// 测试环境
  static const String DEBUG = "http://im.debug.591.com.hk/";

  /// 正式环境
  static const String RELEASE100 = "https://api.100.com.tw/";

  /// 测试环境
  static const String DEBUG100 = "https://api.debug.100.com.tw/";

  /// web socket 测试环境
  static const String SOCKET_DEBUG = "wss://im.debug.591.com.hk/wss";

  /// web socket 线上环境
  static const String SOCKET_RELEASE = "wss://im.100.com.tw/wss";

  /// 删除会话数据
  static const String CLEAR_MESSAGE = "chat/lastMsgClear";

  /// 消息设置已读
  static const String READ_MESSAGE = "chat/readMsg";

  /// 聊天界面联系人列表
  static const String CONTACT_LIST = "chat/users";

  /// 获取会话双方信息
  static const String CONVERSATION_INFO = "chat/getConversationInfo";

  /// 获取新消息总数
  static const String NEW_MESSAGE_COUNT = "chat/getAllNewMessage";

  /// 上线广播
  static const String ONLINE_NOTICE = "messages/onlineNotice";

  /// 删除联络人
  static const String DELETE_CONTACT = "messages/delLiaisonPerson";

  /// 消息到达回调
  static const String MESSAGE_ARRIVAL = "messages/messageArrival";

  /// 发消息
  static const String SEND_MESSAGE = "messages/send";
  /// 图片上传
  static const String UPLOAD_IMAGE = "messages/pictureUpload";

  /// 消息同步
  static const String SYNC_MESSAGE = "messages/messageSynchronization";

  /// 获取历史消息
  static const String HISTORY_MESSAGE = "messages/getHistoricalMessage";

  /// 获取服务器的时间戳 加密字符串使用
  static const String CURRENT_TIMESTAMP = "common/getTimestamp";


}
