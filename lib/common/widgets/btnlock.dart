import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './loading.dart';
import '../values/constanins.dart';

Widget mainlockbtn(
    {@required VoidCallback? onTap,
    bool islock = false,
    bool isloading = false}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedSwitcher(
      duration: defaultDuration,
      switchInCurve: Curves.easeInOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: isloading == true
          ? LoadingWidget(loadingsize: 46)
          : islock == true
              ? SvgPicture.asset(
                  "assets/icons/door_lock.svg",
                  key: ValueKey("lock"), //加这一行识别动画的key
                )
              : SvgPicture.asset("assets/icons/door_unlock.svg",
                  key: ValueKey("unlock")),
    ),
  );
}

Widget lockbtn(
    {@required VoidCallback? onTap, int islock = 0, bool isloading = false}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedSwitcher(
      duration: defaultDuration,
      switchInCurve: Curves.easeInOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: isloading == true
          ? LoadingWidget(loadingsize: 46)
          : islock == 0
              ? SvgPicture.asset(
                  "assets/icons/door_lock.svg",
                  key: ValueKey("lock"), //加这一行识别动画的key
                )
              : SvgPicture.asset("assets/icons/door_unlock.svg",
                  key: ValueKey("unlock")),
    ),
  );
}

Widget locksbbtn(
    {@required VoidCallback? onTap,
    bool isopen = false,
    bool isloading = false}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedSwitcher(
      duration: defaultDuration,
      switchInCurve: Curves.easeInOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: isloading == true
          ? LoadingWidget(loadingsize: 46)
          : isopen == true
              ? SvgPicture.asset(
                  "assets/icons/sb_lock.svg",
                  key: ValueKey("lock"), //加这一行识别动画的key
                )
              : SvgPicture.asset("assets/icons/sb_unlock.svg",
                  key: ValueKey("unlock")),
    ),
  );
}

Widget lockacbtn(
    {@required VoidCallback? onTap,
    bool isopen = false,
    bool isloading = false}) {
  return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: defaultDuration,
        switchInCurve: Curves.easeInOutBack,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: isloading == true
            ? LoadingWidget(loadingsize: 46)
            : isopen == true
                ? SvgPicture.asset("assets/icons/coolShape.svg",
                    color: primaryColor, key: ValueKey("lock"))
                : SvgPicture.asset("assets/icons/coolShape.svg",
                    color: Colors.white38, key: ValueKey("unlock")),
      ));
}
