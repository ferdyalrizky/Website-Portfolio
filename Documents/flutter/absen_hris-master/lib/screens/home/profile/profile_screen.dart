import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/about.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/edukasi/form_edukasi_screen.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/ganti_password.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/keluarga/form_keluarga_screen.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/pekerjaan/form_pekerjaan_screen.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/pribadi/form_pribadi_screen.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/privacy/keamanan_privasi.dart';
import 'package:hris_v2/screens/login/login_screen.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/custom_snackbar_content.dart';
import 'components/profile_list_card.dart';

import 'components/profile_banner_column.dart';

class ProfileScreen extends StatefulWidget {
  final Karyawan currUser;
  final Function profPictCallback;
  const ProfileScreen(
      {super.key, required this.currUser, required this.profPictCallback});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future _onLogoutBtnPress() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  //?[START Helper Method]
  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF0277B7),
        fontSize: 16.0.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  //?[END Helper Method]

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Mengatur apakah pop diizinkan
      onPopInvoked: (didPop) async {
        // Tampilkan dialog konfirmasi saat pop dicoba
        if (!didPop) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Kamu sudah yakin ingin keluar dari',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'aplikasi ini?',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Kalau sudah keluar kamu bisa login menggunakan',
                    style: TextStyle(
                      color: const Color(0xFF585858),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "NIP maupun Email",
                    style: TextStyle(
                      color: const Color(0xFF585858),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 131.w,
                      height: 40.r,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cek dulu deh',
                          style: TextStyle(
                            color: const Color(0xFF142638),
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 120.r,
                      height: 40.h,
                      child: TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          await _onLogoutBtnPress();

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: CustomSnackbarContent(
                                title: "Success",
                                msg: "Logout Berhasil",
                                contentType: ContentType.success,
                              ),
                            ),
                          );

                          SystemNavigator.pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: LightColors.kFagettiBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Yakin dong',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: LightColors.kFagettiBlue,
        ),
        body: SafeArea(
          child: Column(
            children: [
              ProfileBannerColumn(
                name: widget.currUser.namaKaryawan!,
                jobTitle: widget.currUser.jobTitle!,
                nip: widget.currUser.nip!,
                photoUrl: widget.currUser.profilePhotoUrl!,
                onCallback: widget.profPictCallback,
                apiToken: widget.currUser.apiToken!,
                kryId: widget.currUser.id!,
                divisi: widget.currUser.divisi!,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15).w,
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 10).r,
                        child: subheading("Data Pribadi"),
                      ),
                      ProfileListCard(
                        title: "Pekerjaan",
                        icon: Icons.person,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  FormProfilePekerjaanScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
                      ),
                      ProfileListCard(
                        title: "Pribadi",
                        icon: Icons.home,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  FormProfilePribadiScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
                      ),
                      ProfileListCard(
                        title: "Keluarga",
                        icon: Icons.group,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProfileKeluargaScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
                      ),
                      ProfileListCard(
                        title: "Edukasi",
                        icon: Icons.school,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  FormEdukasiScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10).r,
                        child: subheading("Tentang"),
                      ),
                      ProfileListCard(
                        title: "Tentang Aplikasi",
                        icon: Icons.info,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const AboutScreen()),
                          );
                        },
                      ),
                      ProfileListCard(
                        title: "Ganti Password",
                        icon: Icons.lock,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  GantiPasswordScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10).r,
                        child: subheading("Bantuan"),
                      ),
                      ProfileListCard(
                        title: "Keamanan Privasi",
                        icon: Icons.shield,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const KeamananPrivasi()),
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Kamu sudah yakin ingin keluar dari',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'aplikasi ini?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Kalau sudah keluar kamu bisa login menggunakan',
                                    style: TextStyle(
                                      color: const Color(0xFF585858),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "NIP maupun Email",
                                    style: TextStyle(
                                      color: const Color(0xFF585858),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 131.w,
                                      height: 40.r,
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        style: TextButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.black),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Cek dulu deh',
                                          style: TextStyle(
                                            color: const Color(0xFF142638),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 120.w,
                                      height: 40.h,
                                      child: TextButton(
                                        onPressed: () async {
                                          final navigator =
                                              Navigator.of(context);
                                          final scaffoldMessenger =
                                              ScaffoldMessenger.of(context);

                                          await _onLogoutBtnPress();

                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              elevation: 0,
                                              backgroundColor:
                                                  Colors.transparent,
                                              content: CustomSnackbarContent(
                                                title: "Success",
                                                msg: "Logout Berhasil",
                                                contentType:
                                                    ContentType.success,
                                              ),
                                            ),
                                          );

                                          navigator.pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const LoginScreen(),
                                              ),
                                              (route) => false);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              LightColors.kFagettiBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Yakin dong',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5.0.w),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/logout.svg",
                                    width: 28.w,
                                    height: 28.h,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      "Keluar",
                                      style: TextStyle(
                                          color: const Color(0xFFB31312),
                                          fontSize: 18.0.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                color: const Color(0xFFDBDBDB),
                                height: 1,
                                width: 400.w,
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //![END Screen Build]
}
