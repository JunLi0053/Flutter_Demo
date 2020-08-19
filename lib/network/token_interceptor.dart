import 'dart:async';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_app_demo/event/token_expired_event.dart';
import 'package:flutter_app_demo/models/user_entity.dart';
import 'package:flutter_app_demo/network/http_manager.dart';
import 'package:flutter_app_demo/network/server_code.dart';

class TokenInterceptor extends Interceptor {
  @override
  Future onResponse(Response response) async {
    if (ServerCode.TOKEN_EXPIRED_CODE == response.data['code']) {
      // token过期
      UserEntity.instance.token = "";
      EventBus().fire(new userTokenExpiredEvent());
    }
  }

  @override
  Future onRequest(RequestOptions options) async {
    String token = UserEntity.instance.token;
    HttpManager().setToken(token ?? "76D0F4CAAAD430E8A15F8170632B9A35");
  }
}
