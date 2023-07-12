import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tesla_animated_app/screens/global.dart';

class DIO {
  static final DIO _instance = DIO._internal();
  factory DIO() => _instance;
  String token = Global.getstr('token')!;
  static const String BASE_URL_CN = "https://owner-api.vn.cloud.tesla.cn";
  late Dio dio;

  DIO._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      // 请求基地址,可以包含子路径
      baseUrl: BASE_URL_CN,
      // baseUrl: SERVER_API_URL,

      // baseUrl: storage.read(key: STORAGE_KEY_APIURL) ?? SERVICE_API_BASEURL,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: const Duration(seconds: 10),

      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(seconds: 5),

      // Http请求头.
      headers: {},

      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 `Headers.formUrlEncodedContentType`,  这样[Dio]
      /// 就会自动编码请求体.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] 表示期望以那种格式(方式)接受响应数据。
      /// 目前 [ResponseType] 接受三种类型 `JSON`, `STREAM`, `PLAIN`.
      ///
      /// 默认值是 `JSON`, 当响应头中content-type为"application/json"时，dio 会自动将响应内容转化为json对象。
      /// 如果想以二进制方式接受响应数据，如下载一个二进制文件，那么可以使用 `STREAM`.
      ///
      /// 如果想以文本(字符串)格式接收响应数据，请使用 `PLAIN`.
      responseType: ResponseType.json,
    );

    dio = Dio(options);
  }

  /// restful get 操作
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    print(path);
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Authorization': 'Bearer ' + token,
        },
      ),
    );
    var res = (response.data is Map || response.data is List)
        ? response.data
        : json.decode(response.data);
    return res;
  }

  /// restful post 操作
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    var response = await dio.post(
      path,
      data: data,
      queryParameters: query,
      options: Options(
        headers: {
          'Authorization': 'Bearer ' + token,
        },
      ),
    );
    return response.data;
  }
}

Future getbyapi(String apiurl) async {
  final result = await DIO().get(apiurl);
  return (result is Map || result is List) ? result : json.decode(result);
}

Future getdatabyapi(String apiurl, Map<String, dynamic> data) async {
  final result = await DIO().get(apiurl, queryParameters: data);
  return (result is Map || result is List) ? result : json.decode(result);
}

Future postbyapi(String apiurl) async {
  final result = await DIO().post(apiurl);
  return (result is Map || result is List) ? result : json.decode(result);
}

Future postdatabyapi(String apiurl, Map<String, dynamic> data) async {
  final result = await DIO().post(apiurl, data: data);
  return (result is Map || result is List) ? result : json.decode(result);
}
