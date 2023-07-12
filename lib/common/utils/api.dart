class url {
  static const String BASE_URL = "https://owner-api.teslamotors.com";
  static const String BASE_URL_CN = "https://owner-api.vn.cloud.tesla.cn";

  static const String BASE_AUTH_URL = "https://auth.tesla.com";
  static const String BASE_AUTH_URL_CN = "https://auth.tesla.cn";

  static const String getcarinfo = '/api/1/vehicles';
  static String carhandle(String vehicleId, String handle) {
    String url = '/api/1/vehicles/$vehicleId/$handle';
    print(url);
    return url;
  }
}
