// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

class DetailKaryawanScreen extends StatefulWidget {
  final Karyawan selectedKaryawan;
  final Karyawan currUser;
  const DetailKaryawanScreen(
      {super.key, required this.selectedKaryawan, required this.currUser});

  @override
  State<DetailKaryawanScreen> createState() => _DetailKaryawanScreenState();
}

class _DetailKaryawanScreenState extends State<DetailKaryawanScreen> {
  bool isLoading = true;
  List<RekapAbsen> rekapAbsenList = [];

  //* Area Kerja
  String bisnis = "";
  String areaKerja = "";
  String department = "";

  //* Edukasi
  String namaInstansi = "";
  String jenjang = "";
  String jurusan = "";

  //* Keluarga
  Keluarga keluargaData = Keluarga();

  _getRekapAbsenSelectedKaryawan() async {
    try {
      final response = await http.get(Uri.parse(
          '$API_URL/v2/getRekapAbsen/${widget.selectedKaryawan.nip}'));
      print(response.body);
      // rekapAbsenList = await json
      //     .decode(response.body)['result']
      //     .map((data) => RekapAbsen.fromJson(data))
      //     .toList();
      rekapAbsenList = (json.decode(response.body) as List)
          .map((data) => RekapAbsen.fromJson(data))
          .toList();
    } catch (e) {
      print(e.toString());
    }
  }

  _getEdukasiSelectedKaryawan() async {
    try {
      final response = await http.get(
          Uri.parse(
              '$API_URL/v2/getPendidikanData/${widget.selectedKaryawan.id}'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${widget.currUser.apiToken}',
          });
      final output = jsonDecode(response.body);
      setState(() {
        namaInstansi = output['nama_instansi'] ?? 'Tidak ada data';
        jenjang = output['jenjang_pendidikan'] ?? 'Tidak ada data';
        jurusan = output['jurusan'] ?? "Tidak ada data";
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _getPekerjaanSelectedKaryawan() async {
    try {
      final response = await http.get(
          Uri.parse(
              '$API_URL/v2/getPekerjaanData/${widget.selectedKaryawan.id}'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${widget.currUser.apiToken}',
          });
      final output = jsonDecode(response.body);
      setState(() {
        bisnis = output['bisnis'];
        areaKerja = output['area_kerja'];
        department = output['department'];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _getKeluargaSelectedKaryawan() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getKeluargaData/${widget.selectedKaryawan.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      keluargaData = Keluarga.fromJson(output);
      print(keluargaData.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  _getSelectedKaryawanData() async {
    setState(() {
      isLoading = true;
    });

    await _getRekapAbsenSelectedKaryawan();
    await _getEdukasiSelectedKaryawan();
    await _getPekerjaanSelectedKaryawan();
    await _getKeluargaSelectedKaryawan();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getSelectedKaryawanData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Detail Karyawan"),
          actions: const [],
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(tabs: [
            Tab(text: 'Data Pribadi'),
            Tab(text: 'Data Absen'),
          ]),
        ),
        body: isLoading
            ? const Center(child: Loader())
            : TabBarView(children: [
                tabDataKaryawan(),
                tabAbsenKaryawan(),
              ]),
      ),
    );
  }

  SafeArea tabDataKaryawan() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailKaryawanText("Nama", widget.selectedKaryawan.namaKaryawan!),
              detailKaryawanText("Department", department),
              dividerColumn(),
              detailKaryawanText("Jenjang Pendidikan Terakhir", jenjang),
              detailKaryawanText("Jurusan", jurusan),
              dividerColumn(),
              detailKaryawanText("Bisnis", bisnis),
              detailKaryawanText("Area Kerja", areaKerja),
              detailKaryawanText(
                  "Tanggal Bergabung", widget.selectedKaryawan.tanggalMasuk!),
              keluargaData.statusNikah != "Belum Menikah"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dividerColumn(),
                        detailKaryawanText(
                            "Status Menikah", keluargaData.statusNikah!),
                        keluargaData.namaAnak1 != ""
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detailKaryawanText(
                                      "Nama Anak 1", keluargaData.namaAnak1!),
                                  detailKaryawanText("Tgl Lahir Anak 1",
                                      keluargaData.dobAnak1!),
                                ],
                              )
                            : Container(),
                        keluargaData.namaAnak2 != ""
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detailKaryawanText(
                                      "Nama Anak 2", keluargaData.namaAnak2!),
                                  detailKaryawanText("Tgl Lahir Anak 2",
                                      keluargaData.dobAnak2!),
                                ],
                              )
                            : Container(),
                        keluargaData.namaAnak3 != ""
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detailKaryawanText(
                                      "Nama Anak 3", keluargaData.namaAnak3!),
                                  detailKaryawanText("Tgl Lahir Anak 3",
                                      keluargaData.dobAnak3!),
                                ],
                              )
                            : Container()
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Column detailKaryawanText(String header, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  SafeArea tabAbsenKaryawan() {
    return SafeArea(
      child: ListView.builder(
        itemCount: rekapAbsenList.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.white,
            shadowColor: Colors.white,
            elevation: 8,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rekapAbsenList[index].bulan!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Hadir\t\t: ${rekapAbsenList[index].hadir!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Telat\t\t: ${rekapAbsenList[index].terlambat!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Izin : ${rekapAbsenList[index].izin!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Sakit : ${rekapAbsenList[index].sakit!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Cuti : ${rekapAbsenList[index].cuti!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Dayoff : ${rekapAbsenList[index].dayoff!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Alfa : ${rekapAbsenList[index].alfa!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Total Jam Lembur : ${rekapAbsenList[index].totalJamLembur!}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Text subAbsensi(String label, String value) {
    return Text(
      "$label\t: $value",
      style: const TextStyle(
        fontSize: 20,
        wordSpacing: 6,
        letterSpacing: 1.0,
      ),
    );
  }

  Column dividerColumn() {
    return const Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Divider(
          thickness: 5,
          height: 10,
          color: Colors.black,
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
