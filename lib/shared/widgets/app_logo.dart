import 'package:flutter/material.dart';

// Widget para la logo de la aplicación

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 300,
    this.padding = const EdgeInsets.only(top: 48),
  });

  final double width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        'lib/assets/smilelogo 1.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
