// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/ganti_hari.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/absen_gantiharimanager.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/absensi_gantihari.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/absensi_hadir.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/absensi_riwayat.dart';

import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:http/http.dart' as http;

class ListAbsen extends StatefulWidget {
  final Karyawan currUser;
  const ListAbsen({super.key, required this.currUser});

  static const route = '/list-absen-screen';

  @override
  State<ListAbsen> createState() => _ListAbsenState();
}

class _ListAbsenState extends State<ListAbsen> {
  bool loadingGetGantiHari = true;
  Karyawan user = Karyawan();

  List<GantiHari> listGantiHariSendiri = [];
  List<GantiHari> listGantiHariAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalGantiHariSendiri = 0;
  int totalGantiHariBelumDikirimSendiri = 0;
  int totalGantiHariMenungguVerifSendiri = 0;
  int totalGantiHariApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  _getGantiHariList() async {
    setState(() {
      loadingGetGantiHari = true;
    });
    try {
      listGantiHariSendiri = [];
      listGantiHariAnakBuah = [];
      listAnakBuah = [];

      totalGantiHariSendiri = 0;
      totalGantiHariBelumDikirimSendiri = 0;
      totalGantiHariMenungguVerifSendiri = 0;
      totalGantiHariApproveSendiri = 0;

      menungguApproveManager = 0;
      menungguVerifHrd = 0;
      sudahApprove = 0;

      final response = await http.get(
        Uri.parse('$API_URL/v2/gantiHari/getData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      for (var gantihari in output) {
        //*Diri sendiri
        if (gantihari['id_karyawan'] == widget.currUser.id) {
          listGantiHariSendiri.add(GantiHari.fromJson(gantihari));
          //* Jumlahin total biaya
          totalGantiHariSendiri++;

          //*Jumlahin berdasarkan status
          if (gantihari['status'] == 0 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            totalGantiHariBelumDikirimSendiri++;
          } else if ((gantihari['status'] == 1 &&
                  gantihari['disetujuhi'] == 0 &&
                  gantihari['diverifikasi'] == 0) ||
              (gantihari['status'] == 1 &&
                  gantihari['disetujuhi'] == 1 &&
                  gantihari['diverifikasi'] == 0)) {
            totalGantiHariMenungguVerifSendiri++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 1) {
            totalGantiHariApproveSendiri++;
          }
        }
        //* anak buah
        else {
          listGantiHariAnakBuah.add(GantiHari.fromJson(gantihari));
          listAnakBuah.add(Karyawan.fromJson(gantihari['karyawan']));
          //*Jumlahin berdasarkan status
          if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            menungguApproveManager++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 0) {
            menungguVerifHrd++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 1) {
            sudahApprove++;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetGantiHari = false;
    });
  }

  void _afterCreateGantiHari(dynamic value) {
    _getGantiHariList();
  }

  @override
  void initState() {
    _getGantiHariList();
    setState(() {
      user = widget.currUser;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int tabControllerLength;
    List<Widget> tabBarViewChildren;
    List<Widget> tabBar;

    if (widget.currUser.level! == 1 || widget.currUser.level! == 3) {
      tabControllerLength = 3;
      tabBarViewChildren = [
        tabAbsenSendiri(),
        tabAbsenRiwayat(),
        tabAbsenGantiHari()
      ];
      tabBar = [
        const Tab(text: 'Pengajuan'),
        const Tab(text: 'Riwayat'),
        const Tab(text: 'Ganti hari'),
      ];
    } else {
      tabControllerLength = 2;
      tabBarViewChildren = [
        tabAbsenSendiri(),
        tabAbsenRiwayat(),
      ];
      tabBar = [
        const Tab(text: 'Absensi'),
        const Tab(text: 'Riwayat'),
      ];
    }
    return DefaultTabController(
      length:
          (widget.currUser.level! == 1 || widget.currUser.level! == 3) ? 3 : 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: null,
          toolbarHeight: 60.w,
          backgroundColor: const Color(0xFF0277B7),
          elevation: 0,
          bottom: widget.currUser.level! >= 1 && widget.currUser.level! <= 5
              ? TabBar(
                  dividerColor: Colors.transparent,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 1, color: Colors.white),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE2E2E2),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  labelColor: Colors.white,
                  tabs: [
                      const Tab(text: 'Absensi'),
                      const Tab(text: 'Riwayat'),
                      if (widget.currUser.level! == 1 ||
                          widget.currUser.level! == 3)
                        const Tab(text: 'Ganti hari')
                    ])
              : null,
        ),
        body: loadingGetGantiHari
            ? const Center(child: Loader())
            : widget.currUser.level! >= 1 && widget.currUser.level! <= 5
                ? TabBarView(
                    children: [
                      tabAbsenSendiri(),
                      tabAbsenRiwayat(),
                      if (widget.currUser.level! == 1 ||
                          widget.currUser.level! == 3)
                        tabAbsenGantiHari()
                    ],
                  )
                : tabAbsenSendiri(),
      ),
    );
  }

  SafeArea tabAbsenSendiri() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1 && widget.currUser.level! <= 5
                ? AbsenOnlineHome(
                    currUser: widget.currUser,
                  )
                : ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
          )
        ],
      ),
    );
  }

  SafeArea tabAbsenRiwayat() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1 && widget.currUser.level! <= 5
                ? AbsenOnlineRiwayat(
                    currUser: widget.currUser,
                  )
                : ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  SafeArea tabAbsenGantiHari() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! == 3
                ? AbsenOnlineGantihari(
                    listGantiHariSendiri: listGantiHariSendiri,
                    currUser: widget.currUser,
                  )
                : widget.currUser.level! >= 1
                    ? AbsenOnlineGantihariManager(
                        listGantiHariAnakBuah: listGantiHariAnakBuah,
                        currUser: widget.currUser,
                      )
                    : ListView.builder(
                        itemCount: listAnakBuah.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container();
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
