import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';

void log2Console(Object object) {
  LogUtil.v(object);
}

/// @desc  自定义日志拦截器
class CustomLogInterceptor extends Interceptor {
  CustomLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.logPrint = log2Console,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object) logPrint;

  @override
  Future onRequest(RequestOptions options) async {
    logPrint('🔔🔔🔔 Request 🔔🔔🔔');
    logPrint("${options.method} uri:${options.uri}");

    if (requestHeader) {
      logPrint('headers: ${options.headers}');
    }

    if (request) {
//      printKV('responseType', options.responseType?.toString());
//      printKV('followRedirects', options.followRedirects);
//      printKV('connectTimeout', options.connectTimeout);
//      printKV('receiveTimeout', options.receiveTimeout);
//      printKV('extra', options.extra);
    }
    if (requestBody) {
      logPrint("请求数据: ${options.data}");
    }

    logPrint("");
  }

  @override
  Future onError(DioError err) async {
    if (error) {
      logPrint('🔥🔥🔥 DioError 🔥🔥🔥');
      logPrint("${err.request.method} uri:${err.request.uri}");
      logPrint("$err");
      if (err.response != null) {
        _printResponse(err.response);
      }
      logPrint("");
    }
  }

  @override
  Future onResponse(Response response) async {
    logPrint("🔔🔔🔔 Response 🔔🔔🔔");
    _printResponse(response);
  }

  void _printResponse(Response response) {
    logPrint("${response.request?.method} uri:${response.request?.uri}");
    if (responseHeader) {
      printKV('statusCode', response.statusCode);
      if (response.isRedirect == true) {
        printKV('redirect', response.realUri);
      }
      if (response.headers != null) {
        logPrint("headers:");
        response.headers.forEach((key, v) => printKV(" $key", v.join(",")));
      }
    }
    if (responseBody) {
      logPrint("返回数据: ${response.toString()}");
    }
    logPrint("");
  }

  printKV(String key, Object v) {
    logPrint('$key: $v');
  }

  printAll(msg) {
    msg.toString().split("\n").forEach(logPrint);
  }
}