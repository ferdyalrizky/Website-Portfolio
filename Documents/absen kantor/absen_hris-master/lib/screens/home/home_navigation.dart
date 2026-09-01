import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/list_absen.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/karyawan.dart';
import 'dashboard/dashboard_2_screen.dart';
import 'profile/profile_screen.dart';

import 'notification/notification_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currIndexPage = 0;
  late PageController _pageController;

  Karyawan currUser = Karyawan();

  bool loadingFirstTimeLoad = true;

  Future _setupUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    currUser.namaKaryawan = pref.getString("nama_karyawan");
    currUser.nama = pref.getString("nama_panggilan");
    currUser.nip = pref.getString("nip");
    currUser.email = pref.getString("email");
    currUser.profilePhotoUrl = pref.getString("gambar");
    currUser.jobTitle = pref.getString("job_title");
    currUser.apiToken = pref.getString("api_token");
    currUser.departemen = pref.getString("departemen");
    currUser.divisi = pref.getString("divisi");
    currUser.divisiId = pref.getInt("divisi_id");

    currUser.id = pref.getInt("user_id");
    currUser.bisnisId = pref.getInt("bisnis_id");
    currUser.areaKerjaId = pref.getInt("area_kerja_id");
    currUser.level = pref.getInt("level");
    currUser.deviceToken = pref.getString("device_token");

    //await _saveDeviceTokenToFirestore(pref.getString("device_token")!);

    setState(() {
      loadingFirstTimeLoad = false;
    });
  }

  onProfilePictureUpdated() async {
    setState(() {
      loadingFirstTimeLoad = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    currUser.profilePhotoUrl = pref.getString("gambar");

    setState(() {
      loadingFirstTimeLoad = false;
    });
  }

  @override
  void initState() {
    _pageController = PageController();
    _setupUser();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  //&[END Lifecycle]

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: loadingFirstTimeLoad
            ? const Center(child: Loader())
            : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currIndexPage = index;
                  });
                },
                children: [
                  DashboardDuaScreen(currUser: currUser),
                  ListAbsen(currUser: currUser),
                  // DailyTask(),
                  ProfileScreen(
                    currUser: currUser,
                    profPictCallback: onProfilePictureUpdated,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Warna bayangan
              spreadRadius: 2, // Jarak bayangan
              blurRadius: 5, // Kelembutan bayangan
              offset: Offset(0, 0), // Posisi bayangan
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: const NavigationBarThemeData(
            indicatorColor: Color(0xFFE6F1F8),
          ),
          child: NavigationBar(
            height: 85.h,
            backgroundColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _currIndexPage,
            destinations: [
              NavigationDestination(
                icon: SvgPicture.asset(
                  'assets/images/rumah.svg',
                  width: 55.w,
                ),
                selectedIcon: SvgPicture.asset(
                  'assets/images/rumahbiru.svg',
                  width: 55.w,
                ),
                label: "Beranda",
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  'assets/images/absenabu.svg',
                  width: 40.w,
                ),
                selectedIcon: SvgPicture.asset(
                  'assets/images/absenbiru.svg',
                  width: 59.w,
                ),
                label: "Absensi",
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  'assets/images/profil.svg',
                  width: 55.w,
                ),
                selectedIcon: SvgPicture.asset(
                  'assets/images/profilbiru.svg',
                  width: 55.w,
                ),
                label: "Profile",
              ),
            ],
            onDestinationSelected: (index) {
              _pageController.jumpToPage(index);
            },
          ),
        ),
      ),
    );
  }
  //![END Screen Build]
}
