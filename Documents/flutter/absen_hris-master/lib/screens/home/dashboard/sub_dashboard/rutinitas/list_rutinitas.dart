import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/aktifitas.dart';
import 'package:hris_v2/models/meeting.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/form_aktifitas.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/from_pertemuan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/summary_rutinitas.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

class ListSpkRutinitasScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListSpkRutinitasScreen({super.key, required this.currUser});

  @override
  State<ListSpkRutinitasScreen> createState() => _ListSpkRutinitasScreenState();
}

class _ListSpkRutinitasScreenState extends State<ListSpkRutinitasScreen> {
  bool isOpen = false;
  bool loadingGetSpk = true;
  Karyawan user = Karyawan();
  List<Meeting> meeting = [];
  List<Aktifitas> aktifitas = [];

  _getMeetingList() async {
    setState(() {
      loadingGetSpk = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/rutinitas/pertemuan'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );

      // Print the response status code and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> output = jsonDecode(response.body);

        // Reset List
        meeting = output.map((json) => Meeting.fromJson(json)).toList();
      } else {
        // Handle non-200 responses
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR ON _getMeeting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load meetings. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loadingGetSpk = false;
    });
  }

  void _afterCreateMeeting(dynamic value) {
    _getMeetingList();
  }

  _onCreateBiayaBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) =>
            FormKlaimRutinitasScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateMeeting);
  }

  _aktifitasList() async {
    setState(() {
      loadingGetSpk = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/rutinitas/aktifitas/list_task'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );

      // Print the response status code and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> output = jsonDecode(response.body);
        // Akses daftar dari objek
        final List<dynamic> dataList =
            output['data']; // Ganti 'data' dengan kunci yang sesuai

        // Reset List
        aktifitas = dataList.map((json) => Aktifitas.fromJson(json)).toList();
      } else {
        // Handle non-200 responses
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR ON _getAktifitas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load meetings. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loadingGetSpk = false;
    });
  }

  void _afterCreateAktifitas(dynamic value) {
    _aktifitasList();
  }

  _onCreateAktifitasBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) =>
            FormKlaimAktifitasScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateAktifitas);
  }

  @override
  void initState() {
    _aktifitasList();
    _getMeetingList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loadingGetSpk
          ? const Center(child: Loader())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SummaryRutinitasScreen(
                      meeting: meeting,
                      aktifitas: aktifitas,
                      currUser: widget.currUser,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: SpeedDial(
        childrenButtonSize: Size(75, 90),
        buttonSize: Size(75, 75),
        backgroundColor: LightColors.kFagettiBlue,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300), // Durasi animasi
          child: AnimatedRotation(
            turns: isOpen ? 0.5 : 0, // Rotasi 180 derajat saat dibuka
            duration: Duration(milliseconds: 300), // Durasi rotasi
            child: Icon(
              isOpen ? Icons.close : Icons.add,
              color: Colors.white,
              size: 35.w,
              key: ValueKey<bool>(isOpen), // Kunci untuk membedakan widget
            ),
          ),
        ),
        onOpen: () =>
            setState(() => isOpen = true), // Mengubah status saat dibuka
        onClose: () =>
            setState(() => isOpen = false), // Mengubah status saat ditutup
        children: [
          SpeedDialChild(
            shape: CircleBorder(),
            child: SizedBox(
                width: 40.w,
                height: 95.h,
                child: SvgPicture.asset('assets/images/aktifitas.svg')),
            label: 'Aktifitas',
            labelShadow: List.empty(),
            labelBackgroundColor: Colors.transparent,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              _onCreateAktifitasBtnPress(user);
            },
          ),
          SpeedDialChild(
            shape: CircleBorder(),
            child: SizedBox(
                width: 40.w,
                height: 95.h,
                child: SvgPicture.asset('assets/images/pertemuan.svg')),
            label: 'Pertemuan',
            labelShadow: List.empty(),
            labelBackgroundColor: Colors.transparent,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              _onCreateBiayaBtnPress(user);
            },
          ),
        ],
      ),
    );
  }
}
