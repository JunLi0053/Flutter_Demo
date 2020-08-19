import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// toast_util
///
/// @Description: 
/// @Author: Jun 
/// @Date: 2020/8/17
class ToastUtil {
  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }
}