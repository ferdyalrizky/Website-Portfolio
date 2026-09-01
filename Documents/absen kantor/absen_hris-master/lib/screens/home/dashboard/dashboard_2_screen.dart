import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/izin.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/components/dasbord_menu_card1.dart';
import 'package:hris_v2/screens/home/dashboard/components/dasbord_menu_card2.dart';
import 'package:hris_v2/screens/home/dashboard/components/dashbord_menu_card4.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/list_sik_cuti_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/list_sik_sakit_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/list_absen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/list_izin.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/list_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/list_spk_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/penilaian/penilaian_list.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/list_rutinitas.dart';
import 'package:hris_v2/screens/home/notification/notification_screen.dart';
import 'package:hris_v2/screens/home/owner_screens/approval_cuti/list_cuti_owner.dart';
import 'package:hris_v2/screens/home/owner_screens/approval_izin/list_izin_owner.dart';
import 'package:hris_v2/screens/home/owner_screens/data_karyawan/list_data_karyawan_screen.dart';
import 'package:http/http.dart' as http;

import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/widgets/top_dashboard.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constant.dart';
import '../../../widgets/custom_snackbar_content.dart';
import '../../../widgets/dialog.dart';
import '../owner_screens/approval_sakit/list_sakit_owner.dart';
import 'components/dashboard_menu_card.dart';

import '../../../theme/colors/light_colors.dart';

class DashboardDuaScreen extends StatefulWidget {
  final Karyawan currUser;
  const DashboardDuaScreen({super.key, required this.currUser});

  @override
  State<DashboardDuaScreen> createState() => _DashboardDuaScreenState();
}

class _DashboardDuaScreenState extends State<DashboardDuaScreen> {
  bool _hasShownTutorial = false;
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey profileKey = GlobalKey();
  GlobalKey popularKey = GlobalKey();
  GlobalKey notificationKey = GlobalKey();
  GlobalKey agendaKey = GlobalKey();
  GlobalKey aktifitasKey = GlobalKey();
  GlobalKey kabarKey = GlobalKey();

  List<Izin> listIzin = [];

  Future _onLogoutBtnPress() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  _versionCheck() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      var response = await http.get(
        Uri.parse('$API_URL/getMobileAppVersion'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      if (output['version'] != packageInfo.version) {
        if (mounted) {
          Dialogs.popUp(
              context, "Terdapat Versi Terbaru! Silahkan Update", _launchUrl());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _launchUrl() async {
    if (Platform.isIOS) {
      if (!await launchUrl(
          Uri.parse(
            URL_IOS_APP_STORE,
          ),
          mode: LaunchMode.externalApplication)) {
        if (mounted) {
          Dialogs.popUp(context, "Failed Open iOS App Store", null);
        }
      }
    } else if (Platform.isAndroid) {
      if (!await launchUrl(Uri.parse(URL_GOOGLE_PLAY_STORE),
          mode: LaunchMode.externalApplication)) {
        if (mounted) {
          Dialogs.popUp(context, "Failed Open Google PlayStore", null);
        }
      }
    } else {
      Dialogs.popUp(context, "Error Platform", null);
    }
  }

  //![START Lifecycle]
  @override
  void initState() {
    _showTutorialCoachmark();
    super.initState();
  }

  Future<void> _showTutorialCoachmark() async {
    final prefs = await SharedPreferences.getInstance();
    _hasShownTutorial = prefs.getBool('hasShownTutorial') ?? false;

    if (!_hasShownTutorial) {
      _initTarget();
      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        pulseEnable: false,
        unFocusAnimationDuration: Duration.zero,
        colorShadow: LightColors.kFagettiBlue,
        alignSkip: Alignment.topRight,
      )..show(context: context);

      prefs.setBool('hasShownTutorial', true);
    }
  }

  void _initTarget() {
    targets = [
      // klaim biaya
      if (Platform.isAndroid) ...[
        TargetFocus(
          identify: "profile-key",
          keyTarget: profileKey,
          shape: ShapeLightFocus.RRect,
          enableTargetTab: true,
          radius: 10,
          contents: [
            TargetContent(
              padding: const EdgeInsets.only(bottom: 50),
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return CoachmarkDesc(
                  gambar: "klaimbiaya",
                  text:
                      "Klaim pengajuan hingga persetujuan reimbursement transportasi dan event.",
                  judul: "Klaim Biaya",
                  onNext: () {
                    controller.next();
                  },
                  onSkip: () {
                    controller.skip();
                  },
                );
              },
            )
          ],
        ),
      ],
      if (Platform.isIOS) ...[
        TargetFocus(
          identify: "profile-key",
          keyTarget: profileKey,
          shape: ShapeLightFocus.RRect,
          enableTargetTab: true,
          radius: 8,
          contents: [
            TargetContent(
              padding: const EdgeInsets.only(bottom: 50),
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return CoachmarkDesc(
                  gambar: "klaimbiaya",
                  text:
                      "Klaim pengajuan hingga persetujuan reimbursement transportasi dan event.",
                  judul: "Klaim Biaya",
                  onNext: () {
                    controller.next();
                  },
                  onSkip: () {
                    controller.skip();
                  },
                );
              },
            )
          ],
        ),
      ],
      //
      TargetFocus(
        identify: "popularkey",
        keyTarget: popularKey,
        shape: ShapeLightFocus.RRect,
        enableTargetTab: true,
        paddingFocus: 20,
        radius: 10,
        color: Colors.black,
        contents: [
          TargetContent(
            padding: const EdgeInsets.only(bottom: 50),
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                gambar: "penilaianwalk",
                text: "Segera Hadir...",
                judul: "Rutinitas",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),
      TargetFocus(
        identify: "notification-key",
        keyTarget: notificationKey,
        shape: ShapeLightFocus.RRect,
        enableTargetTab: true,
        paddingFocus: 10,
        radius: 10,
        color: Colors.black,
        contents: [
          TargetContent(
            padding: const EdgeInsets.only(bottom: 50),
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                gambar: "rutinitaswalk",
                text: "Segera Hadir...",
                judul: "Penilaian",
                next: "Finish",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),
    ];
  }

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }
  //![START Lifecycle]

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      width: 120.w,
                      height: 40.h,
                      child: TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          await _onLogoutBtnPress();

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
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
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              TopContainerDashboard(
                currUser: widget.currUser,
                height: 305.w,
                width: double.infinity.r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 65.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: 6.r, bottom: 6.r, left: 12.r, right: 12.r),
                          decoration: BoxDecoration(
                              color: Color(0xFF0277B7),
                              borderRadius: BorderRadius.circular(40.r)),
                          child: Text(
                            "PT Fajar Gelora Inti",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          NotificationScreen()));
                            },
                            icon: Icon(
                              Icons.notifications_none,
                              size: 29,
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.currUser.profilePhotoUrl == ""
                            ? Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 75.w,
                                      height: 75.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2.r,
                                              blurRadius: 10.r,
                                              color:
                                                  Colors.black.withOpacity(0.1))
                                        ],
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/avatar.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 75.w,
                                      height: 75.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2.r,
                                              blurRadius: 10.r,
                                              color:
                                                  Colors.black.withOpacity(0.1))
                                        ],
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$API_URL_PROFILE_PICT/${widget.currUser.profilePhotoUrl}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 13).r,
                                    child: Text(
                                      "Hai ${widget.currUser.nama!.split(' ')[0].substring(0, 1).toUpperCase()}${widget.currUser.nama!.split(' ')[0].substring(1).toLowerCase()}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: GoogleFonts.epilogue(
                                        fontSize: 22.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.currUser.jobTitle == ""
                                        ? "Job not define"
                                        : widget.currUser.jobTitle!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.sp,
                                        color: Color(0xFF121212),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                flex: 3,
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(),
                    widget.currUser.level != 99
                        ?
                        //* Not CEO
                        SliverPadding(
                            padding: EdgeInsets.only(
                                top: 8.h,
                                bottom: 20.h,
                                left: 20.w,
                                right: 20.w),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 0,
                                childAspectRatio: 1,
                              ),
                              delegate: SliverChildListDelegate(
                                [
                                  DashboardMenuCard(
                                    title: "Sakit",
                                    gambar: "sakit",
                                    circleColor: CustomTheme.kCrayolaGreen,
                                    press: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return ListSikSakitKaryawanScreen(
                                          currUser: widget.currUser,
                                        );
                                      }));
                                    },
                                  ),
                                  DashboardMenuCard(
                                    title: "Izin",
                                    gambar: "izin",
                                    circleColor: const Color(0xFFA37B73),
                                    press: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ListIzin(
                                                    currUser: widget.currUser,
                                                  )));
                                    },
                                  ),
                                  DashboardMenuCard(
                                    title: "Cuti",
                                    gambar: "cuti",
                                    circleColor: CustomTheme.kPurpleSendBtn,
                                    press: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return ListSikCutiKaryawanScreen(
                                            currUser: widget.currUser);
                                      }));
                                    },
                                  ),
                                  DashboardMenuCard(
                                    title: "Lembur",
                                    gambar: "lembur",
                                    circleColor: CustomTheme.kGreen,
                                    press: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return ListSpkLemburScreen(
                                          currUser: widget.currUser,
                                        );
                                      }));
                                    },
                                  ),
                                  if (Platform.isAndroid) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7).w,
                                      key: profileKey,
                                      child: DashboardMenuCard1(
                                        title: "Klaim biaya",
                                        gambar: "biaya",
                                        press: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return ListKlaimBiayaScreen(
                                              currUser: widget.currUser,
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4.5).w,
                                      key: popularKey,
                                      child: DashboardMenuCard2(
                                        title: "Rutinitas",
                                        gambar: "rutinitas",
                                        press: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (
                                            BuildContext context,
                                          ) {
                                            return ListSpkRutinitasScreen(
                                              currUser: widget.currUser,
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6).w,
                                      key: notificationKey,
                                      child: DashboardMenuCard1(
                                        title: "Penilaian",
                                        gambar: "penilaian1",
                                        circleColor: const Color(0xFF7EA2AA),
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          Penilaian(
                                                            currUser:
                                                                widget.currUser,
                                                          )));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3).w,
                                      child: DashboardMenuCard4(
                                        title: "Konseling",
                                        gambar: "konseling",
                                        circleColor: const Color(0xFFE57A44),
                                        press: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  KonselingScreen(
                                                currUser: widget.currUser,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  if (Platform.isIOS) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 9).r,
                                      key: profileKey,
                                      child: DashboardMenuCard1(
                                        title: "Klaim biaya",
                                        gambar: "biaya",
                                        press: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return ListKlaimBiayaScreen(
                                              currUser: widget.currUser,
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4.5).w,
                                      key: popularKey,
                                      child: DashboardMenuCard2(
                                        title: "Rutinitas",
                                        gambar: "rutinitas",
                                        press: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (
                                            BuildContext context,
                                          ) {
                                            return ListSpkRutinitasScreen(
                                              currUser: widget.currUser,
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8).w,
                                      key: notificationKey,
                                      child: DashboardMenuCard1(
                                        title: "Penilaian",
                                        gambar: "penilaian1",
                                        circleColor: const Color(0xFF7EA2AA),
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          Penilaian(
                                                            currUser:
                                                                widget.currUser,
                                                          )));
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        :
                        //* CEO

                        SliverPadding(
                            padding: EdgeInsets.only(
                                top: 12.h,
                                bottom: 10.h,
                                left: 10.w,
                                right: 10.w),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                                crossAxisCount: 4,
                              ),
                              delegate: SliverChildListDelegate(
                                [
                                  DashboardMenuCard(
                                    title: "Approval Izin",
                                    gambar: "izin",
                                    circleColor: const Color(0xFFA37B73),
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ListIzinOwner(
                                            currUser: widget.currUser,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  DashboardMenuCard(
                                    title: "Approval Sakit",
                                    gambar: "sakit",
                                    circleColor: CustomTheme.kCrayolaGreen,
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return ListSakitOwner(
                                              currUser: widget.currUser,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  DashboardMenuCard(
                                    title: "Approval Cuti",
                                    gambar: "cuti",
                                    circleColor: CustomTheme.kPurpleSendBtn,
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return ListCutiOwner(
                                                currUser: widget.currUser);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  DashboardMenuCard1(
                                    title: "Data Karyawan",
                                    gambar: "penilaian",
                                    circleColor: CustomTheme.kGreen,
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return ListKaryawanScreen(
                                              currUser: widget.currUser,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        Container(
                          color: const Color(0xFFE2E2E2),
                          height: 3.h,
                          width: double.infinity.w,
                        ),
                        Padding(
                          padding: EdgeInsets.all(22.0.w),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ada agenda hari ini?",
                                          style: GoogleFonts.epilogue(
                                              color: Colors.black,
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          "Lihat Semua",
                                          style: TextStyle(
                                            color: const Color(0xFF0277B7),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 26.h,
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/kalender6.svg",
                                      width: 160.w,
                                      height: 80.h,
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Text(
                                      "Hari ini tidak ada agenda yang terjadwal.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Aktifitas",
                                          style: GoogleFonts.epilogue(
                                              color: Colors.black,
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          "Lihat semua",
                                          style: TextStyle(
                                            color: const Color(0xFF0277B7),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/notes.svg",
                                      width: 160.w,
                                      height: 80.h,
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Text(
                                      "Hari ini tidak ada aktifitas yang terjadwal.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Kabar kantor",
                                          style: GoogleFonts.epilogue(
                                              color: Colors.black,
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/kabar1.svg",
                                      width: 200.w,
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Text(
                                      "Hari ini tidak ada kabar kantor.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  //![END Screen Build]

  Widget buildCarouselImage(String urlImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        color: Colors.grey,
        child: Image.asset(urlImage),
      );
}

class CoachmarkDesc extends StatefulWidget {
  const CoachmarkDesc({
    super.key,
    required this.text,
    required this.judul,
    required this.gambar,
    this.skip = "Lewati",
    this.next = "Next",
    this.onSkip,
    this.onNext,
  });

  final String text;
  final String judul;
  final String gambar;
  final String skip;
  final String next;
  final void Function()? onSkip;
  final void Function()? onNext;

  @override
  State<CoachmarkDesc> createState() => _CoachmarkDescState();
}

class _CoachmarkDescState extends State<CoachmarkDesc> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        right: 20,
        left: 20,
        bottom: 10,
        top: 8,
      ).r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 65.w,
                  child: Image.asset(
                    'assets/images/${widget.gambar}.png',
                  ),
                ),
                Expanded(flex: 0, child: SizedBox(width: 20.w)),
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.judul,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          widget.text,
                          style: TextStyle(
                              color: const Color(0xFF585858), fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40,
                      ).r,
                      child: IconButton(
                          onPressed: widget.onSkip,
                          icon: const Icon(
                            Icons.close,
                            size: 25,
                            color: Color(0xFF787878),
                          )),
                    )),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120.r,
                  height: 40.r,
                  child: ElevatedButton(
                    onPressed: widget.onSkip,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4), // adjust the radius here
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: LightColors.kFagettiBlue, width: 1),
                    ),
                    child: Text(
                      widget.skip,
                      style: const TextStyle(
                          color: LightColors.kFagettiBlue), // text color
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.w,
                ),
                SizedBox(
                  width: 120.r,
                  height: 40.r,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4), // adjust the radius here
                      ),
                      backgroundColor: LightColors.kFagettiBlue,
                    ),
                    child: Text(
                      widget.next,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
