import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.zuriWhite,
      body: Center(
        child: Image(
          image: AssetImage('public/images/logo.png'),
          width: 148,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
