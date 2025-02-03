import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aplikasi_gudang/screens/menu_profile/info_card.dart';
import 'package:aplikasi_gudang/screens/menu_profile/side_menu_tile.dart';

class SideMenuProfile extends StatefulWidget {
  const SideMenuProfile({super.key});

  @override
  State<SideMenuProfile> createState() => _SideMenuProfileState();
}

class _SideMenuProfileState extends State<SideMenuProfile> {
  int _activeMenuIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color(0xFF17203A),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              name: "Ferdy Al Rizky",
              nip: "0993",
            ),
            SizedBox(
              height: 50.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2, bottom: 16),
              child: Text(
                "Browse".toUpperCase(),
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Divider(
                color: Colors.white24,
                height: 1,
              ),
            ),
            SideMenuTile(
              press: () {
                setState(() {
                  _activeMenuIndex = 0; // Set active index to 0 for Home
                });
              },
              title: "Home",
              icon: Icons.home,
              isActive:
                  _activeMenuIndex == 0, // Check if this is the active menu
            ),
            SideMenuTile(
              press: () {
                setState(() {
                  _activeMenuIndex = 1; // Set active index to 1 for Sigma
                });
              },
              title: "Sigma",
              icon: Icons.person,
              isActive:
                  _activeMenuIndex == 1, // Check if this is the active menu
            ),
            SideMenuTile(
              press: () {
                setState(() {
                  _activeMenuIndex =
                      2; // Set active index to 2 for Tentang Aplikasi
                });
              },
              title: "Tentang Aplikasi",
              icon: Icons.abc,
              isActive:
                  _activeMenuIndex == 2, // Check if this is the active menu
            ),
            SideMenuTile(
              press: () {
                setState(() {
                  _activeMenuIndex = 3; // Set active index to 3 for Keluar
                });
              },
              title: "Keluar",
              icon: Icons.logout,
              isActive:
                  _activeMenuIndex == 3, // Check if this is the active menu
            ),
          ],
        )),
      ),
    );
  }
}
