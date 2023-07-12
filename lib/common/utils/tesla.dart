import 'dart:convert';

import "package:http/http.dart" as http;

class TeslaService {
  String _ownerapiClientId =
      "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3";
  String _redirectUri = "https://auth.tesla.com/void/callback";
  String _codeVerifier =
      '81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef21067963841234334232123232323232';

  // ignore: missing_return
  String getTeslaAuthorizeUrl() {
    String url =
        "https://auth.tesla.com/oauth2/v3/authorize?client_id=ownerapi&redirect_uri=https://auth.tesla.com/void/callback&response_type=code&scope=openid%20email%20offline_access&code_challenge=lwyXW65CA8kjNd90TP4FzeQGTztjZcQ_fxlzwikCNAs&code_challenge_method=S256&state=teslaSwift";
    return url;
  }

  dynamic getOauth2Token(authCode) async {
    try {
      Map<String, String> payload = {
        "grant_type": "authorization_code",
        "client_id": "ownerapi",
        "code_verifier": _codeVerifier,
        "code": authCode,
        "redirect_uri": _redirectUri,
      };
      var response = await http.post(
        Uri.parse("https://auth.tesla.com/oauth2/v3/token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      return jsonDecode(response.body);
    } catch (err) {
      print("Unable to exchange Auth Code for Oauth2 Token.");
    }
  }

  dynamic getVehicles(token) async {
    try {
      var response = await http.get(
        Uri.parse("https://owner-api.vn.cloud.tesla.cn/api/1/vehicles"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      return jsonDecode(response.body);
    } catch (err) {
      print("Unable to exchange Auth Code for Oauth2 Token.");
    }
  }

  dynamic refreshAccessToken(asToken) async {
    try {
      Map<String, String> payload = {
        "grant_type": "refresh_token",
        "client_id": "ownerapi",
        "refresh_token": asToken,
        "scope": "openid email offline_access"
      };

      var tokenResponse = await http.post(
        Uri.parse("https://auth.tesla.cn/oauth2/v3/token"),
        body: payload,
      );
      return jsonDecode(tokenResponse.body);
    } catch (err) {
      print("Unable to obtain Owner API Access Token");
    }
  }

  dynamic getOwnerApiAccessToken(oauth2Token) async {
    //作废
    try {
      Map<String, String> payload = {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "client_id": _ownerapiClientId,
      };

      var tokenResponse = await http.post(
        Uri.parse("https://auth.tesla.com/oauth2/v3/token"),
        // Uri.parse("https://owner-api.teslamotors.com/oauth/token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $oauth2Token"
        },
        body: jsonEncode(payload),
      );
      return jsonDecode(tokenResponse.body);
    } catch (err) {
      print("Unable to obtain Owner API Access Token");
    }
  }
}
