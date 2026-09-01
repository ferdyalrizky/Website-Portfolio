import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:hris_v2/widgets/top_riwayatabsen.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../../models/data_absen.dart';
import '../../../../../../models/karyawan.dart';
import '../../../../../../utils/constant.dart';

class AbsenOnlineRiwayat extends StatefulWidget {
  final Karyawan currUser;
  const AbsenOnlineRiwayat({super.key, required this.currUser});

  @override
  State<AbsenOnlineRiwayat> createState() => _AbsenOnlineRiwayatState();
}

class _AbsenOnlineRiwayatState extends State<AbsenOnlineRiwayat> {
  List<RekapAbsen> rekapAbsenList = [];
  bool isLoadingGetAbsen = true;
  String? _selectedMonth;

  Future<List<RekapAbsen>> _getRekapAbsenSelectedKaryawan() async {
    final response = await http
        .get(Uri.parse('$API_URL/v2/getRekapAbsen/${widget.currUser.nip}'));

    rekapAbsenList = (json.decode(response.body) as List)
        .map((data) => RekapAbsen.fromJson(data))
        .toList();

    return rekapAbsenList;
  }

  @override
  void initState() {
    super.initState();
    _getRekapAbsenSelectedKaryawan().then((value) {
      setState(() {
        rekapAbsenList = value;

        // Mendapatkan bulan saat ini
        String currentMonth = DateFormat('MMMM').format(DateTime.now());

        // Mencari bulan saat ini dalam daftar rekapAbsenList
        if (rekapAbsenList.isNotEmpty) {
          // Mengatur _selectedMonth ke bulan saat ini jika ada dalam daftar
          _selectedMonth = rekapAbsenList
                  .map((rekapAbsen) => rekapAbsen.bulan)
                  .contains(currentMonth)
              ? currentMonth
              : rekapAbsenList.last.bulan;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getRekapAbsenSelectedKaryawan(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            rekapAbsenList = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Header
                Container(
                  color: const Color(0xFF0277B7),
                  child: RPadding(
                    padding: const EdgeInsets.only(
                            top: 20, right: 12, left: 12, bottom: 12)
                        .r,
                    child: DropdownButtonFormField<String>(
                      iconEnabledColor: Colors.black,
                      value: _selectedMonth,
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10).r,
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        // Use hint instead of labelText
                        label: null,
                        labelText: _selectedMonth == null ? "Pilih bulan" : "",
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 13.sp),

                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 15,
                          right: 15,
                        ).r,
                      ),
                      items: rekapAbsenList.map((rekapAbsen) {
                        return DropdownMenuItem<String>(
                          value: rekapAbsen.bulan,
                          child: Text(
                            rekapAbsen.bulan!,
                            style: TextStyle(fontSize: 13.sp),
                            overflow: TextOverflow.visible,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: _selectedMonth != null
                      ? TopRiwayatAbsen(
                          key: Key(_selectedMonth!),
                          currUser: widget.currUser,
                          bulan: _selectedMonth!,
                        )
                      : Container(),
                ),
              ],
            );
          } else {
            return const Center(
              child: Loader(),
            );
          }
        },
      ),
    );
  }
}
