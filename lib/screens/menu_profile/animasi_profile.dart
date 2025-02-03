import 'dart:math';

import 'package:flutter/material.dart';
import 'package:aplikasi_gudang/screens/home/home_navigation.dart';
import 'package:aplikasi_gudang/screens/menu_profile/menu_btn.dart';
import 'package:aplikasi_gudang/screens/menu_profile/rive_utils.dart';
import 'package:aplikasi_gudang/screens/menu_profile/side_menu.dart';
import 'package:rive/rive.dart';

class AnimasiProfile extends StatefulWidget {
  const AnimasiProfile({super.key});

  @override
  State<AnimasiProfile> createState() => _AnimasiProfileState();
}

class _AnimasiProfileState extends State<AnimasiProfile>
    with SingleTickerProviderStateMixin {
  late SMIBool isSideBarClosed;
  bool isSideMenuClosed = true;
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalanimation;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: 0.8).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    scalanimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17203A),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            width: 288,
            right: isSideMenuClosed ? 288 : 0,
            height: MediaQuery.of(context).size.height,
            child: const SideMenuProfile(),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-animation.value + 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(-animation.value * 365, 0),
              child: Transform.scale(
                scale: scalanimation.value,
                child: ClipRRect(
                    borderRadius: isSideMenuClosed
                        ? const BorderRadius.all(Radius.circular(0))
                        : const BorderRadius.all(Radius.circular(24)),
                    child: const HomeNavigation()),
              ),
            ),
          ),
          MenuBtn(
            riveOnInit: (artboard) {
              final controller = StateMachineController.fromArtboard(
                  artboard, "State Machine");

              artboard.addController(controller!);

              isSideBarClosed = controller.findInput<bool>("isOpen") as SMIBool;
              isSideBarClosed.value = true;
            },
            press: () {
              isSideBarClosed.value = !isSideBarClosed.value;
              if (isSideMenuClosed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
              setState(() {
                isSideMenuClosed = isSideBarClosed.value;
              });
            },
          ),
        ],
      ),
    );
  }
}
