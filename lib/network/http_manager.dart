import 'dart:core';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_demo/models/response_entity.dart';
import 'package:flutter_app_demo/network/api.dart';
import 'package:flutter_app_demo/network/token_interceptor.dart';

import 'http_error.dart';
import 'log_interceptor.dart';

enum RequestMethod { GET, POST, DELETE, PUT }

///使用：NWMethodValues[NWMethod.POST]
const RequestMethodValues = {
  RequestMethod.GET: "get",
  RequestMethod.POST: "post",
  RequestMethod.DELETE: "delete",
  RequestMethod.PUT: "put"
};

///http请求成功回调
typedef HttpSuccessCallback<T> = void Function(ResponseEntity<T> data);

///失败回调
typedef HttpFailureCallback = void Function(HttpError error);

class HttpManager {
  ///同一个CancelToken可以用于多个请求，当一个CancelToken取消时，所有使用该CancelToken的请求都会被取消，一个页面对应一个CancelToken。
  Map<String, CancelToken> _cancelTokens = Map<String, CancelToken>();

  ///超时时间
  static const int CONNECT_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 60000;

  Dio _client;
  static final HttpManager _instance = HttpManager._internal();

  factory HttpManager() => _instance;

  HttpManager._internal() {
    Api.configAPI( ServerType.DEV, tmp: "");

    if (_client == null) {
      BaseOptions options = BaseOptions(
        baseUrl: Api.baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );
      _client = Dio(options);
      _client.interceptors.addAll([new CustomLogInterceptor(), new TokenInterceptor()]);
//      (_client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
//        client.badCertificateCallback=(X509Certificate cert, String host, int port){
//          return true;
//        };
//      };
    }
  }

  void setToken(String token) {
    _client.options.headers = {'token': token};
  }

  ///Get网络请求
  ///
  ///[url] 网络请求地址不包含域名
  ///[params] url请求参数支持restful
  ///[successCallback] 请求成功回调
  ///[failureCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void get<T>({
    @required String url,
    Map<String, dynamic> params,
    HttpSuccessCallback<T> successCallback,
    HttpFailureCallback failureCallback,
    @required String tag,
  }) async {
    _request(
      url: url,
      params: params,
      method: RequestMethod.GET,
      successCallback: successCallback,
      failureCallback: failureCallback,
      tag: tag,
    );
  }

  ///post网络请求
  ///
  ///[url] 网络请求地址不包含域名
  ///[data] post 请求参数
  ///[successCallback] 请求成功回调
  ///[failureCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void post<T>({
    @required String url,
    data,
    HttpSuccessCallback<T> successCallback,
    HttpFailureCallback failureCallback,
    @required String tag,
  }) async {
    _request<T>(
      url: url,
      data: data,
      method: RequestMethod.POST,
      successCallback: successCallback,
      failureCallback: failureCallback,
      tag: tag,
    );
  }

  ///统一网络请求
  ///
  ///[url] 网络请求地址不包含域名
  ///[data] post 请求参数
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[failureCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void _request<T>({
    @required String url,
    RequestMethod method,
    data,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback<T> successCallback,
    HttpFailureCallback failureCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    bool connect = await checkNetWorkConnectivity(failureCallback);
    if (!connect) return;

    //设置默认值
    params = params ?? {};
    method = method ?? RequestMethod.GET;

    options?.method = RequestMethodValues[method];
    options = options ??
        Options(
          method: RequestMethodValues[method],
        );

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken = getCancelTokenWithTag(tag);

      Response<Map<String, dynamic>> response = await _client.request(url,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);
      //成功
      if (successCallback != null) {
        ResponseEntity responseEntity = ResponseEntity<T>.fromJson(response.data);
        successCallback(responseEntity);
      }
    } on DioError catch (e, s) {
      if (failureCallback != null && e.type != DioErrorType.CANCEL) {
        failureCallback(HttpError.dioError(e));
      }
    } catch (e, s) {
      LogUtil.e("未知异常出错：$e\n$s");
      if (failureCallback != null) {
        failureCallback(HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
      }
    }
  }

  ///下载文件
  ///
  ///[url] 下载地址
  ///[savePath]  保存路径
  ///[onReceiveProgress]  下载进度回调
  ///[data] post 请求参数
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[failureCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void download({
    @required String url,
    @required savePath,
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> params,
    data,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback failureCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    bool connect = await checkNetWorkConnectivity(failureCallback);
    if (!connect) return;

    ////0代表不设置超时
    int receiveTimeout = 0;
    if (options == null)
      Options(receiveTimeout: receiveTimeout, responseType: ResponseType.bytes);
    else
      options.merge(
          receiveTimeout: receiveTimeout, responseType: ResponseType.bytes);

    //设置默认值
    params = params ?? {};

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken = getCancelTokenWithTag(tag);

      Response response = await _client.download(url, savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: params,
          data: data,
          options: options,
          cancelToken: cancelToken);
      //成功
      if (successCallback != null) {
        successCallback(response.data);
      }
    } on DioError catch (e, s) {
      if (failureCallback != null && e.type != DioErrorType.CANCEL) {
        failureCallback(HttpError.dioError(e));
      }
    } catch (e, s) {
      LogUtil.e("未知异常出错：$e\n$s");
      if (failureCallback != null) {
        failureCallback(HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
      }
    }
  }

  ///上传文件
  ///
  ///[url] 网络请求地址不包含域名
  ///[data] post 请求参数
  ///[onSendProgress] 上传进度
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[failureCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void upload({
    @required String url,
    FormData data,
    ProgressCallback onSendProgress,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback failureCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    bool connect = await checkNetWorkConnectivity(failureCallback);
    if (!connect) return;

    //设置默认值
    params = params ?? {};

    //强制 POST 请求
    options?.method = RequestMethodValues[RequestMethod.POST];

    options = options ??
        Options(
          method: RequestMethodValues[RequestMethod.POST],
        );

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken = getCancelTokenWithTag(tag);

      Response<Map<String, dynamic>> response = await _client.request(url,
          onSendProgress: onSendProgress,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);
      String statusCode = response.data["code"];
      if (statusCode == "0") {
        //成功
        if (successCallback != null) {
          successCallback(response.data["data"]);
        }
      } else {
        //失败
        String message = response.data["message"];
        LogUtil.v("请求服务器出错：$message");
        if (failureCallback != null) {
          failureCallback(HttpError(statusCode, message));
        }
      }
    } on DioError catch (e, s) {
      if (failureCallback != null && e.type != DioErrorType.CANCEL) {
        failureCallback(HttpError.dioError(e));
      }
    } catch (e, s) {
      LogUtil.e("未知异常出错：$e\n$s");
      if (failureCallback != null) {
        failureCallback(HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
      }
    }
  }

  ///restful处理
  String _restfulUrl(String url, Map<String, dynamic> params) {
    // restful 请求处理
    // /gysw/search/hist/{user_id}      user_id=27
    // 最终生成 url 为     /gysw/search/hist/27
    params.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll('{$key}', value.toString());
      }
    });
    return url;
  }

  ///取消网络请求
  void cancel(String tag) {
    if (_cancelTokens.containsKey(tag)) {
      if (!_cancelTokens[tag].isCancelled) {
        _cancelTokens[tag].cancel();
      }
      _cancelTokens.remove(tag);
    }
  }

  ///检查网络连接
  Future<bool> checkNetWorkConnectivity(
      HttpFailureCallback failureCallback) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (failureCallback != null) {
        failureCallback(HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
      }
      LogUtil.v("请求网络异常，请稍后重试！");
      return false;
    }
    return true;
  }

  ///根据tag获取CancelToken
  ///[tag] 请求标记
  CancelToken getCancelTokenWithTag(String tag) {
    CancelToken cancelToken;
    if (tag != null) {
      cancelToken =
          _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
      _cancelTokens[tag] = cancelToken;
    }
    return cancelToken;
  }
}
