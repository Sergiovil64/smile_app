import 'package:flutter/material.dart';

// Widget para la logo de la aplicación

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 300});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Image.asset(
        'lib/assets/smilelogo 1.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
