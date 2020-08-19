import 'dart:io';

/// response_entity
///
/// @Description: 服务端返回数据model
/// @Author: Jun 
/// @Date: 2020/8/14

import 'package:flutter_app_demo/generated/json/base/json_convert_content.dart';

class ResponseEntity<T> {
  int code;
  String message;
  T data;

  ResponseEntity({this.code, this.message, this.data});
  factory ResponseEntity.fromJson(json) {
    return ResponseEntity(
        code: json["code"],
        message: json["message"],
        // data值需要经过工厂转换为我们传进来的类型
        data: JsonConvert.fromJsonAsT<T>(json['data'])
    );
  }

  Map<String, dynamic> responseToJson(ResponseEntity entity) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = entity.code;
    data['message'] = entity.message;
    data['data'] = entity.data;
    return data;
  }
}