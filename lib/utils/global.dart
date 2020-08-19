/// global
///
/// @Description: 全局类
/// @Author: Jun 
/// @Date: 2020/8/14

class Global {
  //dart.vm.product 环境标识位 Release为true debug 为false
  static const bool isRelease = const bool.fromEnvironment("dart.vm.product");
}