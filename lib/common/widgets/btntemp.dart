import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tesla_animated_app/common/values/values.dart';

class TempBtn extends StatelessWidget {
  const TempBtn({
    Key? key,
    required this.svgurl,
    required this.name,
    this.isOpen = false,
    this.opencolor = primaryColor,
    required this.press,
  }) : super(key: key);
  final String svgurl, name;
  final bool isOpen;
  final Color opencolor;
  final VoidCallback press;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press, //传参数 点击事件
      child: Column(
        children: [
          AnimatedContainer(
            curve: Curves.easeInOutBack, //动画样式
            duration: Duration(milliseconds: 200), //动画变大
            width: isOpen ? 76 : 50,
            height: isOpen ? 76 : 50,
            child: SvgPicture.asset(svgurl,
                color: isOpen ? opencolor : Colors.white38),
          ),
          SizedBox(height: defaultPadding / 2),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 1000),
            style: TextStyle(
                fontSize: 16,
                color: isOpen ? opencolor : Colors.white38,
                fontWeight: isOpen ? FontWeight.bold : FontWeight.normal),
            child: Text(
              name.toUpperCase(),
            ),
          )
        ],
      ),
    );
  }
}
