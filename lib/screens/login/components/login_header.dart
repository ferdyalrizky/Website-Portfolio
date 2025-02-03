import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../size_config.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 300.r,
        width: 550.r,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(0),
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/login.png'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
