import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // Import the splash screen package
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aplikasi_gudang/screens/home/home_navigation.dart';
import 'package:aplikasi_gudang/screens/menu_profile/animasi_profile.dart';
import 'package:aplikasi_gudang/screens/menu_profile/side_menu.dart';
import 'screens/login/login_screen.dart';
import 'theme/colors/light_colors.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Making sure orientation only portrait up
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.landscapeLeft,
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Fagetti HRIS',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: LightColors.kDarkBlue,
                displayColor: LightColors.kDarkBlue,
              ),
        ),
        home: const AnimasiProfile(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
