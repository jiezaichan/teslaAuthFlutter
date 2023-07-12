import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tesla_animated_app/common/utils/utils.dart';

/// 全局静态数据
class Global {
  /// 是否第一次打开
  static bool? isFirstOpen = true;

  /// 是否已登录且有token
  static bool? isGetToken = true;

  /// 是否 release
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  /// init
  static Future init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    // 工具初始
    await StorageUtil().init();
    DIO();

    // 读取设备第一次打开
    isFirstOpen = StorageUtil().getBool('isfirstopen');
    if (isFirstOpen == null) {
      isFirstOpen = true;
    }

    // 读取离线用户信息
    var _profileJSON = StorageUtil().getJSON('userinfo');
    if (_profileJSON != null) {
      isGetToken = true;
    }
  }

  // 持久化 bool
  static Future<bool> setbool(String name, bool value) =>
      StorageUtil().setBool(name, value);

  // 持久化 json/array
  static Future<bool> setjson(String name, dynamic value) =>
      StorageUtil().setJSON(
          name, value is Map || value is List ? value : json.encode(value));

  // 持久化 str
  static Future<bool> setstr(String name, String value) =>
      StorageUtil().setString(name, value);

  // 持久化 int
  static Future<bool> setint(String name, int value) =>
      StorageUtil().setInt(name, value);

  //删除
  static Future<bool> del(String name) => StorageUtil().remove(name);

  static bool? getbool(name) => StorageUtil().getBool(name);
  static dynamic getjson(name) => StorageUtil().getJSON(name);
  static String? getstr(name) => StorageUtil().getStr(name);
  static int? getint(name) => StorageUtil().getInt(name);
}
