import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:hris_v2/models/meeting.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/form_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/from_rutinitas.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/list/form_rutinitas.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/summary_rutinitas.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/karyawan.dart';
import '../../../../../models/lembur.dart';

import 'package:http/http.dart' as http;

import '../../../../../widgets/custom_snackbar_content.dart';

class ListSpkRutinitasScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListSpkRutinitasScreen({super.key, required this.currUser});

  @override
  State<ListSpkRutinitasScreen> createState() => _ListSpkRutinitasScreenState();
}

class _ListSpkRutinitasScreenState extends State<ListSpkRutinitasScreen> {
  bool loadingGetSpk = true;
  Karyawan user = Karyawan();
  List<Meeting> meeting = [];

  _getMeetingList() async {
    setState(() {
      loadingGetSpk = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/rutinitas/pertemuan/'),
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

  void _afterCreateSpkl(dynamic value) {
    _getMeetingList();
  }

  _onCreateBiayaBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) =>
            FormKlaimRutinitasScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateSpkl);
  }

  @override
  void initState() {
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
                      currUser: widget.currUser,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: SizedBox(
        height: 75,
        width: 75,
        child: FloatingActionButton(
          backgroundColor: LightColors.kFagettiBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () {
            _onCreateBiayaBtnPress(user);
          },
          child: Icon(
            Icons.add,
            size: 45,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
