import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/approve_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/components/list_item_lembur_spv.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/form_spk_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur/summary_lembur_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur_all_dept/sumarry_spv_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur_all_dept/summary_lembur_all_dept_screen.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/karyawan.dart';
import '../../../../../models/lembur.dart';

import 'package:http/http.dart' as http;

import '../../../../../widgets/custom_snackbar_content.dart';

class ListSpkLemburScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListSpkLemburScreen({super.key, required this.currUser});

  @override
  State<ListSpkLemburScreen> createState() => _ListSpkLemburScreenState();
}

class _ListSpkLemburScreenState extends State<ListSpkLemburScreen> {
  bool loadingGetSpk = true;

  List<Lembur> listLembur = [];

  int totalBelumDikirim = 0;
  int totalBelumDisetujui = 0;
  int totalMenungguVerifHrd = 0;
  int totalApprove = 0;

  bool isShowAll = true;
  bool isShow1 = false;
  bool isShow2 = false;
  bool isShow3 = false;

  _getLemburList() async {
    setState(() {
      loadingGetSpk = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getSpkl/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      //* Reset List
      listLembur = [];
      totalBelumDikirim = 0;
      totalBelumDisetujui = 0;
      totalMenungguVerifHrd = 0;
      totalApprove = 0;

      for (var lembur in output) {
        listLembur.add(Lembur.fromJson(lembur));

        //TODO Benerin perhitungan
        if (lembur['status'] == 0 &&
            lembur['disetujui'] == 0 &&
            lembur['diverifikasi'] == 0) {
          totalBelumDikirim++;
        } else if (lembur['status'] == 1 &&
            lembur['disetujui'] == 0 &&
            lembur['diverifikasi'] == 0) {
          totalBelumDisetujui++;
        } else if (lembur['status'] == 1 &&
            lembur['disetujui'] == 1 &&
            lembur['diverifikasi'] == 0) {
          totalMenungguVerifHrd++;
        } else {
          totalApprove++;
        }
      }
    } catch (e) {
      print('ERROR ON _getLemburList');
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetSpk = false;
    });
  }

  void _afterCreateSpkl(dynamic value) {
    _getLemburList();
  }

  _onCreateSpklBtnPress(Karyawan currUser) {
    if (currUser.level! == 3 || currUser.level! == 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Warning",
            msg: "Lembur hanya dapat dibuat oleh Manager/SPV anda",
            contentType: ContentType.warning,
          ),
        ),
      );
      return;
    }
    Route route = MaterialPageRoute(
        builder: (context) => FormSpkLemburScreen(currUser: currUser));
    Navigator.push(context, route).then((value) => _afterCreateSpkl(value));
  }

  @override
  void initState() {
    _getLemburList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int tabControllerLength;
    List<Widget> tabBarViewChildren;
    List<Widget> tabBar;

    if (widget.currUser.level! <= 2 &&
        (widget.currUser.divisi == "SECURITY" ||
            widget.currUser.divisi == "CAFÉ & KANTIN" ||
            widget.currUser.divisi == "PURCHASING")) {
      tabControllerLength = 3;
      tabBarViewChildren = [
        tabLemburmanajerSpv(),
        tabLembur(),
        tablemburSummary(),
      ];
      tabBar = [
        const Tab(text: 'Pengajuan'),
        const Tab(text: 'Riwayat'),
        const Tab(text: 'Laporan'),
      ];
    } else {
      tabControllerLength = 2;
      tabBarViewChildren = [
        tabLemburmanajerSpv(),
        tabLembur(),
      ];
      tabBar = [
        const Tab(text: 'Pengajuan'),
        const Tab(text: 'Riwayat'),
      ];
    }

    return DefaultTabController(
      length: tabControllerLength,
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
                    SizedBox(width: 20.w), // add some space from the left edge
                    Text(
                      'Lembur',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: GoogleFonts.epilogue().fontFamily),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: widget.currUser.level! >= 1
                ? TabBar(
                    dividerColor: Colors.transparent,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2, color: Colors.black),
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF585858),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          FontWeight.w600, // add thickness or weight here
                    ),
                    labelColor: Colors.black,
                    tabs: [
                        const Tab(text: 'Pengajuan'),
                        const Tab(text: 'Riwayat'),
                        if (widget.currUser.level! <= 2 &&
                            (widget.currUser.divisi == "SECURITY" ||
                                widget.currUser.divisi == "CAFÉ & KANTIN" ||
                                widget.currUser.divisi == "PURCHASING"))
                          const Tab(
                            child: Text('Laporan'),
                          )
                      ])
                : null,
          ),
          body: loadingGetSpk
              ? const Center(child: Loader())
              : widget.currUser.level! >= 1
                  ? TabBarView(
                      children: tabBarViewChildren,
                    )
                  : tabLemburmanajerSpv(),
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
                _onCreateSpklBtnPress(widget.currUser);
              },
              child: const Icon(
                Icons.add,
                size: 45,
                color: Colors.white,
              ),
            ),
          )),
    );
  }

  SafeArea tablemburSpvManager() {
    return SafeArea(
      child: Column(
        children: [
          listLembur.isEmpty
              ? Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                    ),
                    SizedBox(
                        width: 360.w,
                        height: 160.h,
                        child: SvgPicture.asset("assets/images/tidakada.svg")),
                    SizedBox(
                      height: 10.h,
                    ),
                    const Text(
                      "Tidak ada hasil",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: listLembur.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return widget.currUser.level == 1
                          ? SummaryLemburManajer(
                              lembur: listLembur,
                              currUser: widget.currUser,
                            )
                          : ListItemLemburSpv(
                              lembur: listLembur[index],
                              currUser: widget.currUser,
                              onCallback: _getLemburList,
                            );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  SafeArea tabLemburmanajerSpv() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! == 1
                ? SummaryLemburManajer(
                    lembur: listLembur,
                    currUser: widget.currUser,
                  )
                : SummaryLemburSpvScreen(
                    listLembur: listLembur,
                    currUser: widget.currUser,
                  ),
          )
        ],
      ),
    );
  }

  SafeArea tabLembur() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummaryLemburScreen(
                    listLembur: listLembur,
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

  SafeArea tablemburSummary() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! <= 2 &&
                    (widget.currUser.divisi == "SECURITY" ||
                        widget.currUser.divisi == "CAFÉ & KANTIN" ||
                        widget.currUser.divisi == "PURCHASING")
                ? SummaryLemburAllDeptScreen(
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
}
