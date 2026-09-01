import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:hris_v2/widgets/top_riwayatabsen.dart';

import 'package:http/http.dart' as http;

import '../../../../../models/data_absen.dart';
import '../../../../../models/karyawan.dart';
import '../../../../../utils/constant.dart';

class DataAbsenScreen2 extends StatefulWidget {
  final Karyawan currUser;
  const DataAbsenScreen2({super.key, required this.currUser});

  @override
  State<DataAbsenScreen2> createState() => _DataAbsenScreen2State();
}

class _DataAbsenScreen2State extends State<DataAbsenScreen2> {
  List<RekapAbsen> rekapAbsenList = [];
  bool isLoadingGetAbsen = true;
  String? _selectedMonth;

  _getRekapAbsenSelectedKaryawan() async {
    final response = await http
        .get(Uri.parse('$API_URL/v2/getRekapAbsen/${widget.currUser.nip}'));

    rekapAbsenList = (json.decode(response.body) as List)
        .map((data) => RekapAbsen.fromJson(data))
        .toList();
    setState(() {
      isLoadingGetAbsen = false;
    });
  }

  @override
  void initState() {
    _getRekapAbsenSelectedKaryawan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Absen"),
        actions: const [],
        elevation: 0,
        backgroundColor: CustomTheme.kFagettiBlue,
      ),
      body: isLoadingGetAbsen
          ? const Center(
              child: Loader(),
            )
          : Column(
              children: [
                //Header
                DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => TopRiwayatAbsen(
                            currUser: widget.currUser,
                            bulan: _selectedMonth!,
                          ),
                        ),
                      );
                    });
                  },
                  items: rekapAbsenList.map((rekapAbsen) {
                    return DropdownMenuItem<String>(
                      value: rekapAbsen.bulan,
                      child: Text(rekapAbsen.bulan!),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
