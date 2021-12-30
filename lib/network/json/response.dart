import 'dart:convert' show json;

typedef Success<T> = void Function(String message, T data);
typedef Error = void Function(String message);

/// 请求返回值（普通请求）
class Response<T> {
  int code;
  String message;
  T data;

  /// 使用factory constructor来替代overload
  factory Response(
    jsonStr, // json 字符串
    Function decoder, // 将 data 字段的字符串转为对象的方法
    {
    Success<T> onSuccess,
    Error onError,
  }) {
    return jsonStr is String
        ? Response.fromJson(json.decode(jsonStr), decoder, onSuccess, onError)
        : Response.fromJson(jsonStr, decoder, onSuccess, onError);
  }

  /// 数据解析以及回调处理<br>
  /// @param json ：待解析的json字符串<br>
  /// @param fun ：用于解析json数据的函数<br>
  /// @param onSuccess ：请求成功回调（code == 200）<br>
  /// @param onError ：请求失败回调（code != 200）<br>
  Response.fromJson(
      json, Function decoder, Success<T> onSuccess, Error onError) {
    if (json == null) {
      if (onError != null) onError("json数据为空，解析失败");
      return;
    }
    code = json["code"];
    message = json["message"];
    if (code == 200) {
      data = decoder(json["data"]);
      if (onSuccess != null) onSuccess(message, data);
    } else {
      if (onError != null) onError(message);
    }
  }

  @override
  String toString() {
    return 'Response { code: $code, message: $message, data: $data }';
  }
}
