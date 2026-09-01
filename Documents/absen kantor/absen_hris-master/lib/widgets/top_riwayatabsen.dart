import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_v2/models/data_absen.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/data_absen/components/data_absen_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/data_absen/components/list_item_data_absen.dart';
import 'package:hris_v2/size_config.dart';
import 'package:hris_v2/utils/constant.dart';

import 'package:http/http.dart' as http;

import '../../../../../widgets/loader.dart';

class TopRiwayatAbsen extends StatefulWidget {
  final Karyawan currUser;
  final String bulan;
  const TopRiwayatAbsen(
      {super.key, required this.currUser, required this.bulan});

  @override
  State<TopRiwayatAbsen> createState() => _TopRiwayatAbsenState();
}

class _TopRiwayatAbsenState extends State<TopRiwayatAbsen> {
  bool loadingGetAbsen = true;
  List<DataAbsen> listAbsen = [];
  int hadir = 0;
  int telat = 0;
  int sakit = 0;
  int izin = 0;
  int cuti = 0;
  int dayoff = 0;
  int tdkHadir = 0;
  int alpha = 0;
  int totalJamLembur = 0;

  _getAbsenList() async {
    setState(() {
      loadingGetAbsen = true;
    });
    try {
      final response =
          await http.post(Uri.parse('$API_URL/v2/getDetailRekapAbsen'), body: {
        'bulan': widget.bulan,
        'nip': widget.currUser.nip,
      }, headers: {
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      });

      final output = jsonDecode(response.body);

      for (var absen in output) {
        listAbsen.add(DataAbsen.fromJson(absen));
        //Jumlahin hadir atau tidak
        if (absen['hadir'] == 1) {
          hadir++;
        } else {
          tdkHadir++;
        }
        //Jumlahin telat
        if (absen['terlambat'] == 1) {
          telat++;
        }
        if (absen['alfa'] == 1) {
          alpha++;
        }
        if (absen['dayoff'] == 1) {
          dayoff++;
        }
        if (absen['izin'] == 1) {
          izin++;
        }
        if (absen['sakit'] == 1) {
          sakit++;
        }
        if (absen['cuti'] == 1) {
          cuti++;
        }
        if (absen['total_jam_lembur'] == 1) {
          totalJamLembur++;
        }
      }

      setState(() {
        loadingGetAbsen = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    _getAbsenList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loadingGetAbsen
          ? const Center(
              child: Loader(),
            )
          : Column(
              children: [
                DataAbsenHeader(
                  hadir: hadir,
                  telat: telat,
                  tidakHadir: tdkHadir,
                  alpha: alpha,
                  dayoff: dayoff,
                  izin: izin,
                  sakit: sakit,
                  cuti: cuti,
                  totalJamLembur: totalJamLembur,
                  height: getPropotionateScreenHeight(100),
                  width: getProportionateScreenWidth(double.infinity),
                  child: const Column(
                    children: [],
                  ),
                ),
                listAbsen.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listAbsen.length,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListItemDataAbsen(
                                absen: listAbsen[index],
                                currUser: widget.currUser);
                          },
                        ),
                      )
                    : const Center(
                        child: Text("Tidak ada data absen"),
                      ),
              ],
            ),
    );
  }
}
