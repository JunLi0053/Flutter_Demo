enum ServerType {
  /// 测试
  TEST,
  /// 生产
  PRO,
  /// 开发
  DEV,
  /// 预生产
  SIT
}

class Api {
  static String baseUrl, mqttUrl, fileUrl;
  static configAPI(ServerType serverType, {String tmp}) {
    switch (serverType) {
      case ServerType.TEST:
        baseUrl = "";
        mqttUrl = "";
        break;
      case ServerType.PRO:
        baseUrl = "";
        mqttUrl = "";
        break;
      case ServerType.DEV:
        baseUrl = "";
        mqttUrl = "";
        break;
      case ServerType.SIT:
        baseUrl = "";
        mqttUrl = "";
        break;
    }
    baseUrl = tmp == null ? baseUrl : baseUrl + tmp;
    fileUrl = baseUrl + "/files/";
  }

  /// 登录
  static const String URI_REQUEST_LOGIN = "";
}