import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

import 'components/list_cuti_header.dart';
import 'components/list_item_cuti.dart';

class ListCutiOwner extends StatefulWidget {
  final Karyawan currUser;
  const ListCutiOwner({super.key, required this.currUser});

  @override
  State<ListCutiOwner> createState() => _ListCutiOwnerState();
}

class _ListCutiOwnerState extends State<ListCutiOwner> {
  bool isLoading = true;
  List<Sik> listCutiManager = [];
  List<Karyawan> listManager = [];
  int totalCutiManager = 0;
  int totalCutiManagerMenungguApprove = 0;
  int totalCutiManagerMenungguVerif = 0;
  int totalCutiManagerApproved = 0;

  List<Sik> listCutiAnakBuah = [];
  List<Karyawan> listAnakBuah = [];
  int totalCutiAnakBuah = 0;
  int totalCutiAnakBuahMenungguApprove = 0;
  int totalCutiAnakBuahMenungguVerif = 0;
  int totalCutiAnakBuahApproved = 0;

  _getCutiListManager() async {
    setState(() {
      isLoading = true;
    });
    listCutiManager = [];
    totalCutiManager = 0;
    totalCutiManagerMenungguApprove = 0;
    totalCutiManagerMenungguVerif = 0;
    totalCutiManagerApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v2/getCutiManager/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var sik in output) {
      listCutiManager.add(Sik.fromJson(sik));
      totalCutiManager++;

      listManager.add(Karyawan.fromJson(sik['karyawan']));

      if (sik['status'] == 1 &&
          sik['disetujui'] == 0 &&
          sik['diverifikasi'] == 0) {
        totalCutiManagerMenungguApprove++;
      } else if (sik['status'] == 1 &&
          sik['disetujui'] == 1 &&
          sik['diverifikasi'] == 0) {
        totalCutiManagerMenungguVerif++;
      } else if (sik['status'] == 1 &&
          sik['disetujui'] == 1 &&
          sik['diverifikasi'] == 1) {
        totalCutiManagerApproved++;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  _getCutiListAnakBuah() async {
    setState(() {
      isLoading = true;
    });
    listCutiAnakBuah = [];
    totalCutiAnakBuah = 0;
    totalCutiAnakBuahMenungguApprove = 0;
    totalCutiAnakBuahMenungguVerif = 0;
    totalCutiAnakBuahApproved = 0;

    final response = await http.get(
      Uri.parse('$API_URL/v3/lihatSitc/${widget.currUser.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    final output = jsonDecode(response.body);

    for (var sik in output) {
      if (sik['keperluan'] == 'Cuti') {
        listCutiAnakBuah.add(Sik.fromJson(sik));
        totalCutiAnakBuah++;

        listAnakBuah.add(Karyawan.fromJson(sik['karyawan']));

        if (sik['status'] == 1 &&
            sik['disetujui'] == 0 &&
            sik['diverifikasi'] == 0) {
          totalCutiAnakBuahMenungguApprove++;
        } else if (sik['status'] == 1 &&
            sik['disetujui'] == 1 &&
            sik['diverifikasi'] == 0) {
          totalCutiAnakBuahMenungguVerif++;
        } else if (sik['status'] == 1 &&
            sik['disetujui'] == 1 &&
            sik['diverifikasi'] == 1) {
          totalCutiAnakBuahApproved++;
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getCutiListManager();
    _getCutiListAnakBuah();
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
                    'Cuti',
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
          bottom: widget.currUser.level == 1
              ? TabBar(
                  dividerColor: Colors.transparent,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2.w, color: Colors.black),
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
                      Tab(text: 'Saya'),
                      Tab(text: 'Karyawan'),
                    ])
              : null,
        ),
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
        listCutiManager.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: listCutiManager.length,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListItemCuti(
                      thisUser: listManager[index],
                      cuti: listCutiManager[index],
                      currUser: widget.currUser,
                      onCallback: _getCutiListManager,
                    );
                  },
                ),
              )
            : const Center(child: Text("Tidak ada data izin")),
      ],
    );
  }

  Column tabIzinKaryawan() {
    return Column(
      children: [
        listCutiAnakBuah.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: listCutiAnakBuah.length,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListItemCuti(
                      thisUser: listAnakBuah[index],
                      cuti: listCutiAnakBuah[index],
                      currUser: widget.currUser,
                      onCallback: _getCutiListAnakBuah,
                    );
                  },
                ),
              )
            : const Center(child: Text("Tidak ada data Izin")),
      ],
    );
  }
}
