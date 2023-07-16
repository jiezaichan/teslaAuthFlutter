// ignore_for_file: unused_field

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:url_launcher/url_launcher.dart";
import 'package:get/get.dart';
import 'package:tesla_animated_app/common/utils/tesla.dart';
import 'package:tesla_animated_app/common/values/values.dart';
import 'package:tesla_animated_app/common/widgets/widgets.dart';
import 'package:tesla_animated_app/common/utils/utils.dart';
import 'package:tesla_animated_app/screens/global.dart';
import "package:http/http.dart" as http;

class IndexPage extends StatefulWidget {
  IndexPage({Key? key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  // 当前 tab 页码
  int _page = 0;
  //是否去webview登录
  bool isShowWeb = false;
  String _url = '';
  //几个动画初始值

  late AnimationController _tempAnimationController; //温度专用
  late Animation<double> _animationCarMove; //车往右边移动
  late Animation<double> _animationTempShow; //冷暖2个按钮
  late Animation<double> _animationTempLight; //右边灯光右边往左移动

  late AnimationController _tyreAnimationController; //轮胎专用
  late Animation<double> _animationtyre1;
  late Animation<double> _animationtyre2;
  late Animation<double> _animationtyre3;
  late Animation<double> _animationtyre4;

  late List<Animation<double>> _tyreAnimations;
  TeslaService _teslaService = new TeslaService();

  final GlobalKey _webViewKey = GlobalKey();
  late InAppWebViewController _iosWebViewController;
  InAppWebViewGroupOptions _iosWebViewOptions = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  void setuptempAnimation() {
    _tempAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationCarMove =
        Tween(begin: 0.0, end: 1.0).animate(_tempAnimationController)
          ..addListener(() {
            setState(() {});
          });
    _animationTempShow =
        Tween(begin: 0.45, end: 0.65).animate(_tempAnimationController)
          ..addListener(() {
            setState(() {});
          });
    _animationTempLight =
        Tween(begin: 0.1, end: 1.0).animate(_tempAnimationController)
          ..addListener(() {
            setState(() {});
          });
  }

  void setuptyreAnimation() {
    _tyreAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animationtyre1 = CurvedAnimation(
        parent: _tyreAnimationController, curve: Interval(0.5, 0.7));
    _animationtyre2 = CurvedAnimation(
        parent: _tyreAnimationController, curve: Interval(0.6, 0.8));
    _animationtyre3 = CurvedAnimation(
        parent: _tyreAnimationController, curve: Interval(0.7, 0.9));
    _animationtyre4 = CurvedAnimation(
        parent: _tyreAnimationController, curve: Interval(0.8, 1.0));
  }

  Future<void> _exchangeAuthCode(String authCode) async {
    // 通过授权码获取token =>web
    try {
      Map tokenData = await _teslaService.getOauth2Token(authCode);
      setToken(tokenData);
      setState(() {
        isShowWeb = !isShowWeb;
      });
      await Future.delayed(Duration(milliseconds: 120));
      String token = Global.getstr('token') ?? '';
      var res = await _teslaService.getVehicles(token);
      print('res');
      print(res);
      String id = res['response'][0]['id'].toString();
      String vid = res['response'][0]['vehicle_id'].toString();
      Global.setstr('id', id);
      Global.setstr('vid', vid);
      wakeAndGetCarInfo();
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    setuptempAnimation();
    setuptyreAnimation();
    _tyreAnimations = [
      _animationtyre1,
      _animationtyre2,
      _animationtyre3,
      _animationtyre4
    ];
    Global.del('getcarinfounix');
    if (Global.getstr("carname") != null) {
      //如果本地存了车辆的名字
      setState(() {
        _carname = Global.getstr("carname")!;
      });
    }
    if (Global.getstr("carlocation") != null) {
      //如果本地存了地址
      setState(() {
        _locationtext = Global.getstr("carlocation")!;
      });
    }
    if (Global.getjson("carinfo") != null) {
      //如果本地存了车辆
      setState(() {
        carinfo = Global.getjson("carinfo");
      });
    }
    if (Global.getbool("iscaropen") != null) {
      //如果本地存了主lock
      setState(() {
        _isleftlock = Global.getbool("iscaropen")!;
      });
    }
    if (Global.getbool("isacopen") != null) {
      //如果本地存了aclock
      setState(() {
        _isacopen = Global.getbool("isacopen")!;
      });
    }
    if (Global.getbool("issbopen") != null) {
      //如果本地存了sblock
      setState(() {
        _issbopen = Global.getbool("issbopen")!;
      });
    }

    //这里判断一下是否有token
    init();
    super.initState();
  }

  @override
  void dispose() {
    _tempAnimationController.dispose();
    _tyreAnimationController.dispose();
    Global.del('getcarinfounix');
    super.dispose();
  }

  @override
  // ignore: override_on_non_overriding_member
  bool _isleftlock = true;
  int _isheadlock = 0;
  int _istrucklock = 0;
  // ignore: override_on_non_overriding_member
  bool _iscoolopen = false;
  num _tempnum = 20;
  num _tempinsidenum = 20;

  bool _issbopen = false;
  bool _isacopen = false;
  bool _isloadingget = false;
  bool _isbackloadingget = false;
  bool _issbloadingget = false;
  bool _isacloadingget = false;
  bool _isshowtyre = false;
  bool _isshowtyretemp = false;
  String _loadingtext = "";
  String _carname = "未知车辆";
  String _locationtext = "未知地点";
  int _carkm = 0;
  int _carlevel = 0;
  Map carinfo = {};

  void clickcoolbtn(bool isopencool) {
    setState(() {
      this._iscoolopen = !this._iscoolopen;
    });
  }

  void changetemp(bool isadd, num num) {
    if (this._tempnum >= 35 && isadd) return;
    if (this._tempnum <= 8 && !isadd) return;
    isadd
        ? setState(() {
            this._tempnum = this._tempnum + num;
          })
        : setState(() {
            this._tempnum = this._tempnum - num;
          });
    if (this._tempnum > 20) {
      setState(() {
        this._iscoolopen = false;
      });
    } else {
      this._iscoolopen = true;
    }
  }

  // tab栏页码切换
  void _handlePageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

//getdata func
  void getpage(pageNo) async {
    if (pageNo == 1) {
      int? getcarinfounix = Global.getint('getcarinfounix');
      print(getcarinfounix);
      if (getcarinfounix != null) {
        print('上次请求时间:' +
            DateTime.fromMillisecondsSinceEpoch(getcarinfounix).toString());
      }
      if (getcarinfounix != null && (getunixnow() - getcarinfounix) < 100000) {
        print('100秒内、无需获取');
      } else {
        print('过期或者没有、需要重新获取');
        getcarinfo();
      }
    }
  }

  void showmodel_head(BuildContext context) {
    showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("提示"), // 标题组件
            content: Text(textinfo.ask_head_lock), // 内容组件
            // 按钮组件 List
            actions: [
              CupertinoDialogAction(
                child: Text(textinfo.ask_head_cancel), // 子组件
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(textinfo.ask_head_confim), // 子组件
                // 是否为默认事件，为 true 时会加粗
                isDefaultAction: true,
                // 是否为警告按钮，为 true 时会变成红色
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void getcarinfo() async {
    String id = Global.getstr('id')!;
    Global.del('getcarinfounix');
    setState(() {
      _loadingtext = '加载中';
    });
    final res = await getbyapi(url.carhandle(id, 'vehicle_data'));
    Map carinfo = res["response"];
    String carname = '大土豆';
    // String carname = carinfo["display_name"];
    Global.setjson('carinfo', carinfo);
    Map climate_state = carinfo["climate_state"];
    Map vehicle_state = carinfo["vehicle_state"];
    Map charge_state = carinfo["charge_state"];
    Map drive_state = carinfo["drive_state"];
    // print(climate_state);
    // print(vehicle_state);
    // print(charge_state);
    // print(drive_state);
    String gpx = drive_state["corrected_longitude"].toString() +
        "," +
        drive_state["corrected_latitude"].toString();
    var loca = await http.get(Uri.parse(
        'https://restapi.amap.com/v3/geocode/regeo?output=json&location=' +
            gpx +
            '&key=49521b5942bff4d41e5495698ab5bcb6'));
    Map resloca = jsonDecode(loca.body);
    String locationtext = resloca["regeocode"]["formatted_address"] ?? '未知地点';
    print(locationtext);
    print('检查哨兵');
    print(vehicle_state["sentry_mode"]);
    setState(() {
      _loadingtext = '已驻车';
      _carkm = (charge_state["ideal_battery_range"] * 1.6093).round();
      _carlevel = charge_state["battery_level"];
      _isleftlock = vehicle_state["locked"]; //主锁
      _isheadlock = vehicle_state["ft"]; //前备箱锁
      _istrucklock = vehicle_state["rt"]; //后备箱锁
      _issbopen = vehicle_state["sentry_mode"]; //哨兵锁
      _isacopen = climate_state["is_auto_conditioning_on"]; //空调
      _tempnum = climate_state["driver_temp_setting"]; //默认设置的温度
      _tempinsidenum = climate_state["inside_temp"]; //默认设置的温度
      carinfo = carinfo;
    });
    Global.setbool('isacopen', this._isacopen);
    Global.setbool('issbopen', this._issbopen);
    Global.setbool('iscaropen', this._isleftlock);
    if (locationtext.length > 15) {
      int i = locationtext.indexOf('省');
      String a = locationtext.substring(i + 1, locationtext.length);
      if (a.indexOf('(') > 5) {
        int newi = a.indexOf('(');
        String b = a.substring(0, newi);
        print(b);
        setState(() {
          _locationtext = b;
        });
      } else {
        setState(() {
          _locationtext = a;
        });
      }
    } else {
      setState(() {
        _locationtext = locationtext;
      });
    }

    if (Global.getstr("carname") != carname) {
      Global.setstr("carname", carname);
      print("车名不一样");
      setState(() {
        _carname = carname;
      });
    } else {
      print("车名一样、不需要动");
    }
    Global.setstr('carlocation', _locationtext);
    Global.setint('getcarinfounix', getunixnow());
    print(Global.getint('getcarinfounix'));
  }

  // 初始方法
  void init() async {
    int expunix = Global.getint('unix') ?? 0;
    //1、第一次进入App-打开webview授权页
    if (expunix == 0) {
      print('需要登录');
      setState(() {
        isShowWeb = true;
      });
      //2、token失效-去刷新token-唤醒并获取车辆信息
    } else if (getunixnow() > expunix) {
      print('token过期了');
      refreshToken();
    } else {
      //3、token有效-唤醒并获取车辆信息
      print('token有效');
      wakeAndGetCarInfo();
    }
  }

  //wakeAndGetCarInfo
  void wakeAndGetCarInfo() async {
    String id = Global.getstr('id')!;
    bool isWaked = false;
    // 循环调用 API 直到请求成功
    while (!isWaked) {
      try {
        final wakeres = await postbyapi(url.carhandle(id, 'wake_up'));
        String wakeState = wakeres['response']['state'];
        print('检查是否唤醒:' + wakeState);
        if (wakeState == 'online') {
          isWaked = true;
          // 在此处处理成功响应
          getcarinfo();
        }
      } catch (e) {
        // 在此处处理请求失败的情况
      }
      if (!isWaked) {
        // 等待 1 秒后再次调用 API
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  //刷新token
  void refreshToken() async {
    print('add global unix. astoken:');
    String retoken = Global.getstr('retoken')!;
    var tokenData = await _teslaService.refreshAccessToken(retoken);
    setToken(tokenData);
  }

  //set Token
  void setToken(Map tokenData) {
    print('set token and retoken:');
    String new_token = tokenData['access_token'];
    String new_retoken = tokenData['refresh_token'];
    Global.setstr('token', new_token);
    Global.setstr('retoken', new_retoken);
    //获取当前时间戳
    int unix = getunixnow();
    int expunix = unix + 28800000;
    Global.setint('unix', expunix);
    print('unix is : $expunix');
    print('access_token is : $new_token');
    print('refresh_token is : $new_retoken');
  }

  void mainLock() async {
    if (_isloadingget == true) {
      Get.snackbar("提示", textinfo.lock_notice);
      return;
    }
    setState(() {
      _isloadingget = true;
    });
    if (_isleftlock == true) {
      bool isOk = await handerCar('command/door_unlock'); //解锁主锁
      if (isOk) {
        _isleftlock = false;
      }
    } else {
      bool isOk = await handerCar('command/door_lock'); //主锁
      if (isOk) {
        _isleftlock = true;
      }
    }
    _isloadingget = false;
    setState(() {});
    Global.setbool('iscaropen', _isleftlock);
  }

  void acLock() async {
    if (_isacloadingget == true) {
      Get.snackbar("提示", textinfo.lock_notice);
      return;
    }
    setState(() {
      _isacloadingget = true;
    });
    if (_isacopen == true) {
      bool isOk = await handerCar('command/auto_conditioning_stop'); //关闭空调
      if (isOk) {
        _isacopen = false;
      }
    } else {
      bool isOk = await handerCar('command/auto_conditioning_start'); //开启空调
      if (isOk) {
        _isacopen = true;
      }
    }
    _isacloadingget = false;
    setState(() {});
    Global.setbool('isacopen', _isacopen);
  }

  void sbLock() async {
    if (_issbloadingget == true) {
      Get.snackbar("提示", textinfo.lock_notice);
      return;
    }
    setState(() {
      _issbloadingget = true;
    });
    if (_issbopen == true) {
      bool isOk = await handerCar('/command/set_sentry_mode',
          handData: {"on": "false"}); //关闭哨兵
      if (isOk) {
        _issbopen = false;
      }
    } else {
      bool isOk = await handerCar('command/set_sentry_mode',
          handData: {"on": "true"}); //开启哨兵
      if (isOk) {
        _issbopen = true;
      }
    }
    _issbloadingget = false;
    setState(() {});
    Global.setbool('issbopen', _issbopen);
  }

  void headLock() async {}
  void truckLock() async {
    if (_isbackloadingget == true) {
      Get.snackbar("提示", textinfo.lock_notice);
      return;
    }
    setState(() {
      _isbackloadingget = true;
    });
    bool isOk = await handerCar('/command/actuate_trunk',
        handData: {"which_trunk": "rear"}); //关闭/打开后备箱
    if (isOk) {
      setState(() {
        _istrucklock = this._istrucklock == 0 ? 32 : 0;
        _isbackloadingget = false;
      });
    }
  }

  //执行命令
  Future<bool> handerCar(String handerName,
      {Map<String, dynamic>? handData}) async {
    String id = Global.getstr('id')!;
    bool isWaked = false;
    // 循环调用 API 直到请求成功
    while (!isWaked) {
      try {
        final wakeres = await postbyapi(url.carhandle(id, 'wake_up'));
        String wakeState = wakeres['response']['state'];
        print('检查是否唤醒:' + wakeState);
        if (wakeState == 'online') {
          isWaked = true;
          // 在此处处理成功响应
          final res = handData != null
              ? await postdatabyapi(url.carhandle(id, handerName), handData)
              : await postbyapi(url.carhandle(id, handerName));
          // print(res['response']);
          bool isOk = res["response"].isNotEmpty && res["response"]["result"]
              ? true
              : false;
          return isOk;
        }
      } catch (e) {
        // 在此处处理请求失败的情况
        return false; // 添加一个返回语句
      }
      if (!isWaked) {
        // 等待 1 秒后再次调用 API
        await Future.delayed(Duration(seconds: 1));
      }
    }
    // 添加一个终止函数的返回语句
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(
        onTap: (index) {
          //点击底部Tab
          getpage(index + 1);
          if (index == 2) {
            _tempAnimationController.forward().whenComplete(() => {}); //执行动画
          } else if (this._page == 2 && index != 2) {
            _tempAnimationController.reverse(from: 0.4); //回滚动画
          }

          if (index == 3) {
            if (this._page == 2) {
              Future.delayed(Duration(milliseconds: 300), () {
                _tyreAnimationController.forward();
                setState(() {
                  this._isshowtyre = true;
                  this._isshowtyretemp = true;
                });
              });
            } else {
              _tyreAnimationController.forward();
              setState(() {
                this._isshowtyre = true;
                this._isshowtyretemp = true;
              });
            }
          } else if (this._page == 3 && index != 3) {
            setState(() {
              this._isshowtyre = false;
            });
            _tyreAnimationController.reverse(from: 0.85);
            Future.delayed(Duration(milliseconds: 400), () {
              setState(() {
                this._isshowtyretemp = false;
              });
            });
          }

          _handlePageChanged(index);
        },
        selectedTab: this._page,
      ),
      body: isShowWeb
          ? InAppWebView(
              key: _webViewKey,
              // contextMenu: contextMenu,
              initialUrlRequest: URLRequest(
                url: Uri.parse(_teslaService.getTeslaAuthorizeUrl()),
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialOptions: _iosWebViewOptions,
              onWebViewCreated: (controller) {
                _iosWebViewController = controller;
              },
              onLoadStart: (controller, uri) {
                setState(() {
                  _url = uri.toString();
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url;

                if (uri
                    .toString()
                    .contains("https://auth.tesla.com/void/callback?code")) {
                  Map queryParams = Uri.parse(uri.toString()).queryParameters;

                  await _exchangeAuthCode(queryParams['code']);

                  return NavigationActionPolicy.CANCEL;
                }

                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri?.scheme)) {
                  if (await canLaunch(_url)) {
                    // Launch the App
                    await launch(
                      _url,
                    );

                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
            )
          : SafeArea(child: LayoutBuilder(builder: (context, constrains) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Column(
                  //   children: [
                  //     // ElevatedButton(
                  //     //     onPressed: () async {
                  //     //       Global.del('token');
                  //     //       Global.del('retoken');
                  //     //       Global.del('unix');
                  //     //       setState(() {
                  //     //         isShowWeb = !isShowWeb;
                  //     //       });
                  //     //     },
                  //     //     child: Text('打开webview')),
                  //     // ElevatedButton(
                  //     //     onPressed: () async {
                  //     //       String retoken = Global.getstr('retoken') ?? '';
                  //     //       var tokenData =
                  //     //           await _teslaService.refreshAccessToken(retoken);
                  //     //       print('add global unix. astoken:');
                  //     //       String new_retoken = tokenData['refresh_token'];
                  //     //       String new_token = tokenData['access_token'];
                  //     //       print(tokenData);
                  //     //       Global.setstr('token', new_token);
                  //     //       Global.setstr('retoken', new_retoken);
                  //     //     },
                  //     //     child: Text('刷新token')),
                  //     Spacer(),
                  //     ElevatedButton(
                  //         onPressed: wakeAndGetCarInfo, child: Text('test')),
                  //   ],
                  // ),
                  SizedBox(
                    height: constrains.maxHeight,
                    width: constrains.maxWidth,
                  ),
                  if (this._page == 0) ...buildtopinfo(context),
                  Positioned(
                    left: constrains.maxWidth / 2 * _animationCarMove.value,
                    height: constrains.maxHeight,
                    width: constrains.maxWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: constrains.maxHeight * 0.1),
                      child: SvgPicture.asset(
                        "assets/icons/Car.svg",
                        width: double.infinity,
                      ),
                    ),
                  ),
                  ...buildlocksview(context, constrains),
                  if (this._page == 0)
                    Positioned(
                      width: 375.w,
                      bottom: 10.h,
                      child: Text(
                        _locationtext,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  AnimatedOpacity(
                    duration: defaultDuration,
                    opacity: this._page == 1 ? 1 : 0,
                    child: SvgPicture.asset(
                      "assets/icons/Battery.svg",
                      width: constrains.maxWidth * 0.45,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: defaultDuration,
                    opacity: this._page == 1 ? 1 : 0,
                    child: AnimatedContainer(
                      duration: defaultDuration,
                      height: this._page == 1
                          ? constrains.maxHeight
                          : constrains.maxHeight * 0.9,
                      child: buildbatteryview(context, constrains),
                    ),
                  ),
                  Positioned(
                    height: constrains.maxHeight,
                    width: constrains.maxWidth,
                    top: 60 * (1 - _animationTempShow.value),
                    child: Opacity(
                      opacity: _animationTempShow.value,
                      child: buildtempview(context, constrains),
                    ),
                  ),
                  if (this._page == 2)
                    Positioned(
                      right: -1800 * (1 - _animationTempLight.value),
                      child: AnimatedSwitcher(
                        duration: defaultDuration,
                        child: this._iscoolopen
                            ? Image.asset(
                                "assets/images/Cool_glow_2.png",
                                width: 200,
                                key: UniqueKey(),
                              )
                            : Image.asset(
                                "assets/images/Hot_glow_4.png",
                                width: 200,
                                key: UniqueKey(),
                              ),
                      ),
                    ),
                  if (this._isshowtyre) ...buildtyresview(context, constrains),
                  if (this._isshowtyretemp)
                    GridView.builder(
                      itemCount: 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: defaultPadding,
                        crossAxisSpacing: defaultPadding,
                        childAspectRatio:
                            constrains.maxWidth / constrains.maxHeight,
                      ),
                      itemBuilder: (BuildContext context, int index) =>
                          ScaleTransition(
                        scale: _tyreAnimations[index],
                        child: buildtyrecard(
                          carinfo: carinfo,
                          carname: _carname,
                          locationtext: _locationtext,
                        ),
                      ),
                    ),
                ],
              );
            })),
    );
  }

//顶部的车名字跟里程
  List<Widget> buildtopinfo(BuildContext context) {
    return [
      Positioned(
        left: 15.w,
        top: 8.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _carname,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                if (_loadingtext != "已驻车")
                  Container(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                        color: Color(0xFF858585), strokeWidth: 2.6),
                  ),
                if (_loadingtext != "已驻车") SizedBox(width: 5.w),
                Text(_loadingtext,
                    style: TextStyle(
                        color: Color(0xFF858585),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp)),
              ],
            )
          ],
        ),
      ),
      Positioned(
        right: 15.w,
        top: 12.h,
        child: Row(
          children: [
            Text(
              _carkm > 0 ? _carkm.toString() : '',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              _carkm > 0 ? "km" : '',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ];
  }

//4个lock
  List<Widget> buildlocksview(BuildContext context, BoxConstraints constrains) {
    return [
      AnimatedPositioned(
        //主锁
        duration: defaultDuration,
        left: this._page == 0
            ? constrains.maxWidth * 0.05
            : constrains.maxWidth / 2,
        child: AnimatedOpacity(
          duration: defaultDuration,
          opacity: this._page == 0 ? 1 : 0,
          child: mainlockbtn(
              onTap: () => mainLock(),
              islock: _isleftlock,
              isloading: _isloadingget),
        ),
      ),
      AnimatedPositioned(
        //空调
        duration: defaultDuration,
        right: this._page == 0
            ? constrains.maxWidth * 0.05
            : constrains.maxWidth / 2,
        child: Container(
          width: 53,
          height: 53,
          child: AnimatedOpacity(
            duration: defaultDuration,
            opacity: this._page == 0 ? 1 : 0,
            child: lockacbtn(
                onTap: acLock, isopen: _isacopen, isloading: _isacloadingget),
          ),
        ),
      ),
      AnimatedPositioned(
        //哨兵
        duration: defaultDuration,
        right: this._page == 0
            ? constrains.maxWidth * 0.05
            : constrains.maxWidth / 2,
        bottom: this._page == 0
            ? constrains.maxHeight * 0.17
            : constrains.maxHeight / 2,
        child: Container(
          width: 53,
          height: 53,
          child: AnimatedOpacity(
            duration: defaultDuration,
            opacity: this._page == 0 ? 1 : 0,
            child: locksbbtn(
                onTap: sbLock, isopen: _issbopen, isloading: _issbloadingget),
          ),
        ),
      ),
      AnimatedPositioned(
        //前备箱
        duration: defaultDuration,
        top: this._page == 0
            ? constrains.maxHeight * 0.13
            : constrains.maxHeight / 2,
        child: AnimatedOpacity(
          duration: defaultDuration,
          opacity: this._page == 0 ? 1 : 0,
          child: lockbtn(
              onTap: () {
                if (this._isheadlock == 0)
                  showmodel_head(context);
                else {
                  setState(() {
                    this._isheadlock = 1;
                  });
                }
              },
              islock: this._isheadlock),
        ),
      ),
      AnimatedPositioned(
        //后备箱
        duration: defaultDuration,
        bottom: this._page == 0
            ? constrains.maxHeight * 0.17
            : constrains.maxHeight / 2,
        child: AnimatedOpacity(
          duration: defaultDuration,
          opacity: this._page == 0 ? 1 : 0,
          child: lockbtn(
              onTap: truckLock,
              islock: _istrucklock,
              isloading: _isbackloadingget),
        ),
      ),
    ];
  }

//电池info
  Widget buildbatteryview(BuildContext context, BoxConstraints constrains) {
    return Column(
      children: [
        Text(_carkm.toString() + " km",
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Colors.white)),
        Text(
          _carlevel.toString() + " %",
          style: TextStyle(fontSize: 24),
        ),
        Spacer(),
        Text(
          "假装充电中…".toUpperCase(),
          style: TextStyle(fontSize: 20),
        ),
        Text(
          "剩余时长 18 分钟",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: constrains.maxHeight * 0.14),
        DefaultTextStyle(
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("23 km/hr"),
              Text("234 v"),
            ],
          ),
        ),
        SizedBox(
          height: defaultPadding,
        )
      ],
    );
  }

//温度info
  Widget buildtempview(BuildContext context, BoxConstraints constrains) {
    Map climate_state = carinfo["climate_state"] ?? {};
    String inTemp = climate_state["inside_temp"].toString() + "\u2103";
    String outTemp = climate_state["outside_temp"].toString() + "\u2103";
    return this._page == 2
        ? Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      TempBtn(
                        isOpen: this._iscoolopen ? true : false,
                        svgurl: "assets/icons/coolShape.svg",
                        name: "冷风",
                        opencolor: primaryColor,
                        press: () => clickcoolbtn(true),
                      ),
                      SizedBox(width: defaultPadding),
                      TempBtn(
                        isOpen: !this._iscoolopen ? true : false,
                        svgurl: "assets/icons/heatShape.svg",
                        name: "暖风",
                        opencolor: redColor,
                        press: () => clickcoolbtn(false),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => changetemp(true, 0.5),
                      icon: Icon(Icons.arrow_drop_up, size: 48),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      // width: 360,
                      child: Text(_tempnum.toString() + "\u2103",
                          style: TextStyle(fontSize: 86)),
                    ),
                    IconButton(
                      onPressed: () => changetemp(false, 0.5),
                      icon: Icon(Icons.arrow_drop_down, size: 48),
                      padding: EdgeInsets.zero,
                    )
                  ],
                ),
                Spacer(),
                Text("当前温度".toUpperCase()),
                SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("室内温度", style: TextStyle(color: Colors.white54)),
                        Text(inTemp,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white54)),
                      ],
                    ),
                    SizedBox(width: defaultPadding),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("室外温度"),
                        Text(outTemp,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
              ],
            ),
          )
        : Container();
  }

//车轮子
  List<Widget> buildtyresview(BuildContext context, BoxConstraints constrains) {
    return [
      Positioned(
        left: constrains.maxWidth * 0.2,
        top: constrains.maxHeight * 0.22,
        child: SvgPicture.asset("assets/icons/FL_Tyre.svg"),
      ),
      Positioned(
        right: constrains.maxWidth * 0.2,
        top: constrains.maxHeight * 0.22,
        child: SvgPicture.asset("assets/icons/FL_Tyre.svg"),
      ),
      Positioned(
        left: constrains.maxWidth * 0.2,
        top: constrains.maxHeight * 0.63,
        child: SvgPicture.asset("assets/icons/FL_Tyre.svg"),
      ),
      Positioned(
        right: constrains.maxWidth * 0.2,
        top: constrains.maxHeight * 0.63,
        child: SvgPicture.asset("assets/icons/FL_Tyre.svg"),
      ),
    ];
  }
}

//轮子info
class buildtyrecard extends StatelessWidget {
  const buildtyrecard(
      {Key? key,
      required this.carinfo,
      required this.carname,
      required this.locationtext})
      : super(key: key);
  final Map carinfo;
  final String carname;
  final String locationtext;

  @override
  Widget build(BuildContext context) {
    var detext = new TextStyle(fontWeight: FontWeight.normal, fontSize: 16.sp);
    return DefaultTextStyle(
      style: detext,
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: primaryColor, width: 2),
          borderRadius: BorderRadius.all(
            Radius.circular(6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('车辆Api内容:', style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 50.h),
              Text('车辆: ${carname}'),
              Text('状态: ${carinfo["state"].toString()}'),
              Text('vin: ${carinfo["vin"].toString()}'),
              Text(
                  '版本号: ${carinfo["vehicle_state"]["car_version"].toString()}'),
              // Text('车辆id: ${carinfo["id_s"].toString()}'),
              Text('地点: ' + locationtext),

              // Text(carinfo.toString())
            ],
          ),
        ),
      ),
    );
  }

  Text lowText(BuildContext context) {
    return Text(
      "Low".toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .displaySmall!
          .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({
    Key? key,
    required this.selectedTab,
    required this.onTap,
  }) : super(key: key);

  final int selectedTab;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTap,
      currentIndex: selectedTab,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      items: List.generate(
        navIcons.length,
        (index) => BottomNavigationBarItem(
          icon: SvgPicture.asset(
            "assets/icons/${navIcons[index]}.svg",
            color: index == selectedTab ? primaryColor : Colors.white54,
          ),
          label: "",
        ),
      ),
    );
  }
}

List<String> navIcons = ["Lock", "Charge", "Temp", "Tyre"];
