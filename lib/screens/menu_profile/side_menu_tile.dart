import 'package:flutter/material.dart';
import 'package:aplikasi_gudang/theme/colors/light_colors.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.title,
    required this.press,
    required this.isActive,
    required this.icon,
  });
  final String title;
  final VoidCallback press;
  final bool isActive;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AnimatedPositioned(
              height: 56,
              width: isActive ? 288 : 0,
              duration: Duration(
                  milliseconds: 500), // Set a duration for the animation

              child: Container(
                decoration: BoxDecoration(
                    color: Color(
                      0xFF6792FF,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            ListTile(
              onTap: press,
              leading: SizedBox(
                height: 34,
                width: 34,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Divider(
            color: Colors.white24,
            height: 1,
          ),
        ),
      ],
    );
  }
}
