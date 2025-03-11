import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/screens/home/owner_screens/approval_izin/components/list_izin_manager_header.dart';
import 'package:hris_v2/screens/home/owner_screens/approval_sakit/components/list_item_sakit.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

class ListSakitOwner extends StatefulWidget {
  final Karyawan currUser;
  const ListSakitOwner({super.key, required this.currUser});

  @override
  State<ListSakitOwner> createState() => _ListSakitOwnerState();
}

class _ListSakitOwnerState extends State<ListSakitOwner> {
  bool isLoading = true;
  List<Sik> listSakitManager = [];
  List<Karyawan> listManager = [];
  int totalSakitManager = 0;
  int totalSakitManagerMenungguApprove = 0;
  int totalSakitManagerMenungguVerif = 0;
  int totalSakitManagerApproved = 0;

  List<Sik> listSakitAnakBuah = [];
  List<Karyawan> listAnakBuah = [];
  int totalSakitAnakBuah = 0;
  int totalSakitAnakBuahMenungguApprove = 0;
  int totalSakitAnakBuahMenungguVerif = 0;
  int totalSakitAnakBuahApproved = 0;

  _getSakitListManager() async {
    setState(() {
      isLoading = true;
    });
    listSakitManager = [];
    totalSakitManager = 0;
    totalSakitManagerMenungguApprove = 0;
    totalSakitManagerMenungguVerif = 0;
    totalSakitManagerApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v2/getSakitManager/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var sik in output) {
      listSakitManager.add(Sik.fromJson(sik));
      totalSakitManager++;

      listManager.add(Karyawan.fromJson(sik['karyawan']));

      if (sik['status'] == 1 &&
          sik['disetujui'] == 0 &&
          sik['diverifikasi'] == 0) {
        totalSakitManagerMenungguApprove++;
      } else if (sik['status'] == 1 &&
          sik['disetujui'] == 1 &&
          sik['diverifikasi'] == 0) {
        totalSakitManagerMenungguVerif++;
      } else if (sik['status'] == 1 &&
          sik['disetujui'] == 1 &&
          sik['diverifikasi'] == 1) {
        totalSakitManagerApproved++;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  _getSakitListAnakBuah() async {
    setState(() {
      isLoading = true;
    });
    listSakitAnakBuah = [];
    totalSakitAnakBuah = 0;
    totalSakitAnakBuahMenungguApprove = 0;
    totalSakitAnakBuahMenungguVerif = 0;
    totalSakitAnakBuahApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v3/lihatSitc/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var sik in output) {
      if (sik['keperluan'] == "Sakit") {
        listSakitAnakBuah.add(Sik.fromJson(sik));
        totalSakitAnakBuah++;

        listAnakBuah.add(Karyawan.fromJson(sik['karyawan']));

        if (sik['status'] == 1 &&
            sik['disetujui'] == 0 &&
            sik['diverifikasi'] == 0) {
          totalSakitAnakBuahMenungguApprove++;
        } else if (sik['status'] == 1 &&
            sik['disetujui'] == 1 &&
            sik['diverifikasi'] == 0) {
          totalSakitAnakBuahMenungguVerif++;
        } else if (sik['status'] == 1 &&
            sik['disetujui'] == 1 &&
            sik['diverifikasi'] == 1) {
          totalSakitAnakBuahApproved++;
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getSakitListManager();
    _getSakitListAnakBuah();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            bottom: const TabBar(
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
                ])),
        body: isLoading
            ? const Center(child: Loader())
            : TabBarView(
                children: [
                  tabSakitManager(),
                  tabSakitKaryawan(),
                ],
              ),
      ),
    );
  }

  Column tabSakitManager() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: listSakitManager.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return ListItemSakit(
                thisUser: listManager[index],
                sik: listSakitManager[index],
                currUser: widget.currUser,
                onCallback: _getSakitListManager,
              );
            },
          ),
        )
      ],
    );
  }

  Column tabSakitKaryawan() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: listSakitAnakBuah.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return ListItemSakit(
                thisUser: listAnakBuah[index],
                sik: listSakitAnakBuah[index],
                currUser: widget.currUser,
                onCallback: _getSakitListAnakBuah,
              );
            },
          ),
        )
      ],
    );
  }
}
