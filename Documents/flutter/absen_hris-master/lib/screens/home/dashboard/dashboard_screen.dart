import 'package:flutter/material.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/list_sik_cuti_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/list_sik_sakit_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/list_absen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/data_absen2/data_absen_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/list_izin.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/list_spk_lembur.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../utils/constant.dart';
import 'components/dashboard_menu_card.dart';

import '../../../size_config.dart';
import '../../../widgets/top_container.dart';
import '../../../theme/colors/light_colors.dart';

class DashboardScreen extends StatefulWidget {
  final Karyawan currUser;
  const DashboardScreen({super.key, required this.currUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _timeString;
  late Timer _timer;

  //?[START Helper Method]
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }
  //?[END Helper Method]

  //![START Lifecycle]
  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  //![START Lifecycle]

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: LightColors.kFagettiBlue,
        actions: const [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopContainer(
              height: getPropotionateScreenHeight(150),
              margin: const EdgeInsets.only(bottom: 15),
              width: SizeConfig.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        widget.currUser.profilePhotoUrl == ""
                            ? Expanded(
                                flex: 1,
                                child: Container(
                                  width: getProportionateScreenWidth(75),
                                  height: getPropotionateScreenHeight(75),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 4, color: Colors.white),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.1))
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
                              )
                            : Expanded(
                                flex: 1,
                                child: Container(
                                  width: getProportionateScreenWidth(75),
                                  height: getPropotionateScreenHeight(75),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.1))
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
                              ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(right: 13),
                                child: Text(
                                  widget.currUser.namaKaryawan!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                widget.currUser.nip!,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                widget.currUser.jobTitle == ""
                                    ? "Job not define"
                                    : widget.currUser.jobTitle!,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      //mainAxisSpacing: 10,
                      childAspectRatio: 1,
                      crossAxisCount: 2,
                    ),
                    delegate: SliverChildListDelegate(
                      [
                        DashboardMenuCard(
                          title: "Absen Online",
                          gambar: "absen",
                          circleColor: const Color(0xFFE57A44),
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ListAbsen(
                                  currUser: widget.currUser,
                                ),
                              ),
                            );
                          },
                        ),
                        DashboardMenuCard(
                          title: "Lihat History Absen",
                          gambar: "absen",
                          circleColor: const Color(0xFF7EA2AA),
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DataAbsenScreen2(
                                          currUser: widget.currUser,
                                        )));
                          },
                        ),
                        DashboardMenuCard(
                          title: "Lihat History Izin",
                          gambar: "izin",
                          circleColor: const Color(0xFFA37B73),
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => ListIzin(
                                          currUser: widget.currUser,
                                        )));
                          },
                        ),
                        DashboardMenuCard(
                          title: "Lihat History Sakit",
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
                          title: "Lihat History Cuti",
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
                          title: "Lihat SPK Lembur",
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //![END Screen Build]
}
