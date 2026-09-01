import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/components/list_izin_anak_buah_header.dart';
import 'package:hris_v2/screens/home/owner_screens/approval_izin/components/list_izin_manager_header.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

import 'components/list_item_izin_manager.dart';

class ListIzinOwner extends StatefulWidget {
  final Karyawan currUser;
  const ListIzinOwner({super.key, required this.currUser});

  @override
  State<ListIzinOwner> createState() => _ListIzinOwnerState();
}

class _ListIzinOwnerState extends State<ListIzinOwner> {
  bool isLoading = true;
  List<Izin> listIzinManager = [];
  List<Karyawan> listManager = [];
  int totalIzinManager = 0;
  int totalIzinManagerMenungguApprove = 0;
  int totalIzinManagerMenungguVerif = 0;
  int totalIzinManagerApproved = 0;

  List<Izin> listIzinAnakBuah = [];
  List<Karyawan> listAnakBuah = [];
  int totalIzinAnakBuah = 0;
  int totalIzinAnakBuahMenungguApprove = 0;
  int totalIzinAnakBuahMenungguVerif = 0;
  int totalIzinAnakBuahApproved = 0;

  _getIzinListManager() async {
    setState(() {
      isLoading = true;
    });
    listIzinManager = [];
    totalIzinManager = 0;
    totalIzinManagerMenungguApprove = 0;
    totalIzinManagerMenungguVerif = 0;
    totalIzinManagerApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v2/getIzinManager/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var izin in output) {
      listIzinManager.add(Izin.fromJson(izin));
      totalIzinManager++;

      listManager.add(Karyawan.fromJson(izin['karyawan']));

      if (izin['status'] == 1 &&
          izin['disetujuhi'] == 0 &&
          izin['diverifikasi'] == 0) {
        totalIzinManagerMenungguApprove++;
      } else if (izin['status'] == 1 &&
          izin['disetujuhi'] == 1 &&
          izin['diverifikasi'] == 0) {
        totalIzinManagerMenungguVerif++;
      } else if (izin['status'] == 1 &&
          izin['disetujuhi'] == 1 &&
          izin['diverifikasi'] == 1) {
        totalIzinManagerApproved++;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  _getIzinListAnakBuah() async {
    setState(() {
      isLoading = true;
    });
    listIzinAnakBuah = [];
    totalIzinAnakBuah = 0;
    totalIzinAnakBuahMenungguApprove = 0;
    totalIzinAnakBuahMenungguVerif = 0;
    totalIzinAnakBuahApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v3/lihatDtpc/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var izin in output) {
      listIzinAnakBuah.add(Izin.fromJson(izin));
      totalIzinAnakBuah++;

      listAnakBuah.add(Karyawan.fromJson(izin['karyawan']));

      if (izin['status'] == 1 &&
          izin['disetujuhi'] == 0 &&
          izin['diverifikasi'] == 0) {
        totalIzinAnakBuahMenungguApprove++;
      } else if (izin['status'] == 1 &&
          izin['disetujuhi'] == 1 &&
          izin['diverifikasi'] == 0) {
        totalIzinAnakBuahMenungguVerif++;
      } else if (izin['status'] == 1 &&
          izin['disetujuhi'] == 1 &&
          izin['diverifikasi'] == 1) {
        totalIzinAnakBuahApproved++;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getIzinListManager();
    _getIzinListAnakBuah();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 100.w,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30.w,
                  ),
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
                      'Izin',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: GoogleFonts.epilogue().fontFamily),
                    ),
                  ],
                ),
              ],
            ),
            elevation: 0,
            bottom: TabBar(
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
                fontWeight: FontWeight.w600, // add thickness or weight here
              ),
              labelColor: Colors.black,
              tabs: const [
                Tab(text: 'Manager'),
                Tab(text: 'Karyawan'),
              ],
            )),
        body: isLoading
            ? const Center(child: Loader())
            : TabBarView(
                children: [
                  tabIzinManager(),
                  tabIzinKaryawan(),
                ],
              ),
      ),
    );
  }

  Column tabIzinManager() {
    return Column(
      children: [
        ListView.builder(
          itemCount: listIzinManager.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) {
            return ListItemIzinManager(
              thisUser: listManager[index],
              izin: listIzinManager[index],
              currUser: widget.currUser,
              onCallback: _getIzinListManager,
            );
          },
        )
      ],
    );
  }

  Column tabIzinKaryawan() {
    return Column(
      children: [
        ListView.builder(
          itemCount: listIzinAnakBuah.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) {
            return ListItemIzinManager(
              thisUser: listAnakBuah[index],
              izin: listIzinAnakBuah[index],
              currUser: widget.currUser,
              onCallback: _getIzinListAnakBuah,
            );
          },
        )
      ],
    );
  }
}
