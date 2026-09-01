import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/components/list_item_sik_sakit_sendiri.dart';

import 'package:flutter/material.dart';
import 'package:hris_v2/models/sik.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/components/list_item_sik_sakit_anak_buah.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/summary_anakbuah.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/summary_sakit.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

import 'form_sik_sakit_karyawan_screen.dart';

class ListSikSakitKaryawanScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListSikSakitKaryawanScreen({
    super.key,
    required this.currUser,
  });

  @override
  State<ListSikSakitKaryawanScreen> createState() =>
      _ListSikSakitKaryawanScreenState();
}

class _ListSikSakitKaryawanScreenState
    extends State<ListSikSakitKaryawanScreen> {
  bool loadingGetSik = true;
  Karyawan user = Karyawan();

  List<Sik> listSikSendiri = [];
  List<Sik> listSikAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalApproveSendiri = 0;
  int totalMenungguVerifSendiri = 0;
  int totalBelumDikirimSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  @override
  void initState() {
    _getSikList();
    setState(() {
      user = widget.currUser;
    });
    super.initState();
  }

  _getSikList() async {
    setState(() {
      loadingGetSik = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/lihatSitc/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );

      final output = jsonDecode(response.body);
      print(output);

      //*Reset list
      listSikSendiri = [];
      listSikAnakBuah = [];
      listAnakBuah = [];

      totalBelumDikirimSendiri = 0;
      totalApproveSendiri = 0;
      totalMenungguVerifSendiri = 0;

      menungguApproveManager = 0;
      menungguVerifHrd = 0;
      sudahApprove = 0;

      for (var sik in output) {
        if (sik['keperluan'] == "Sakit") {
          //* Diri Sendiri
          if (sik['id_karyawan'] == widget.currUser.id) {
            listSikSendiri.add(Sik.fromJson(sik));
            //* Jumlahin berdasarkan status
            if (sik['status'] == 0 &&
                sik['disetujui'] == 0 &&
                sik['diverifikasi'] == 0) {
              totalBelumDikirimSendiri++;
            } else if ((sik['status'] == 1 &&
                    sik['disetujui'] == 0 &&
                    sik['diverifikasi'] == 0) ||
                (sik['status'] == 1 &&
                    sik['disetujui'] == 1 &&
                    sik['diverifikasi'] == 0)) {
              totalMenungguVerifSendiri++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 1) {
              totalApproveSendiri++;
            }
          }
          //*Karyawan
          else {
            listSikAnakBuah.add(Sik.fromJson(sik));
            listAnakBuah.add(Karyawan.fromJson(sik['karyawan']));
            if (sik['status'] == 1 &&
                sik['disetujui'] == 0 &&
                sik['diverifikasi'] == 0) {
              menungguApproveManager++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 0) {
              menungguVerifHrd++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 1) {
              sudahApprove++;
            }
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetSik = false;
    });
  }

  void _afterCreateSik(dynamic value) {
    setState(() {
      loadingGetSik = true;
    });
    _getSikList();
  }

  _onCreateSikBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => FormSikSakitKaryawanScreen(currUser: currUser));
    Navigator.push(context, route).then(_afterCreateSik);
  }

  @override
  Widget build(BuildContext context) {
    int tabCount = widget.currUser.level == 1 ? 3 : 1;
    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100.w,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Row(
                children: [
                  const SizedBox(
                      width: 20), // add some space from the left edge
                  Text(
                    'Sakit',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.epilogue().fontFamily),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: widget.currUser.level == 1
              ? const TabBar(
                  dividerColor: Colors.transparent,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF585858),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // add thickness or weight here
                  ),
                  labelColor: Colors.black,
                  tabs: [
                      Tab(text: 'Saya'),
                      Tab(text: 'Karyawan'),
                      Tab(text: 'Riwayat'),
                    ])
              : null,
        ),
        body: loadingGetSik
            ? const Center(
                child: Loader(),
              )
            : widget.currUser.level == 1
                ? TabBarView(children: [
                    TabSakitDiriSendiri(),
                    TabSakitDiriAnakBuah(),
                    TabSakitDiriAnakBuahRiwayat(),
                  ])
                : TabSakitDiriSendiri(),
        floatingActionButton: SizedBox(
          height: 75,
          width: 75,
          child: FloatingActionButton(
            backgroundColor: LightColors.kFagettiBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  50), // Set the radius of the FloatingActionButton
            ),
            onPressed: () {
              _onCreateSikBtnPress(user);
            },
            child: const Icon(
              Icons.add,
              size: 45,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  SafeArea TabSakitDiriSendiri() {
    return SafeArea(
      child: Column(
        children: [
          listSikSendiri.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: listSikSendiri.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListItemSikSakitSendiri(
                        sik: listSikSendiri[index],
                        onCallback: _getSikList,
                        currUser: widget.currUser,
                      );
                    },
                  ),
                )
              : Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      SizedBox(
                          width: 320.w,
                          height: 160.h,
                          child:
                              SvgPicture.asset("assets/images/tidakada.svg")),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        "Tidak ada hasil",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  SafeArea TabSakitDiriAnakBuah() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummarySakitAnakbuah(
                    listSakitAnakBuah: listSikAnakBuah,
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

  SafeArea TabSakitDiriAnakBuahRiwayat() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummarySakitRiwayat(
                    listSakitAnakBuah: listSikAnakBuah,
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
          )
        ],
      ),
    );
  }
}
