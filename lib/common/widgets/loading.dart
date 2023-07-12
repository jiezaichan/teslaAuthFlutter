import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, required this.loadingsize}) : super(key: key);
  final double loadingsize;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.loadingsize,
      height: this.loadingsize,
      child: CircularProgressIndicator(
          color: Color(0xFF858585), strokeWidth: loadingsize / 10),
    );
  }
}
