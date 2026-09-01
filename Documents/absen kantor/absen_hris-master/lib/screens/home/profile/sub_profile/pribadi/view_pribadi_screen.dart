import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/profile/sub_profile/pribadi/form_pribadi_screen.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/data_pribadi.dart';

import 'package:http/http.dart' as http;

import '../../../../../models/karyawan.dart';
import '../../../../../utils/constant.dart';

class ViewPersonalDataScreen extends StatefulWidget {
  final Karyawan currUser;
  const ViewPersonalDataScreen({super.key, required this.currUser});

  @override
  State<ViewPersonalDataScreen> createState() => _ViewPersonalDataScreenState();
}

class _ViewPersonalDataScreenState extends State<ViewPersonalDataScreen> {
  DataPribadi currUserDataPribadi = DataPribadi();
  bool isGetDataPribadi = false;

  _onGetDataPribadi() async {
    setState(() {
      isGetDataPribadi = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getPersonalData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      currUserDataPribadi = DataPribadi.fromJson(output);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isGetDataPribadi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pribadi"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return FormProfilePribadiScreen(currUser: widget.currUser);
              }));
            },
            icon: const Icon(Icons.edit),
          ),
        ],
        backgroundColor: CustomTheme.kFagettiBlue,
      ),
      body: isGetDataPribadi
          ? const Center(
              child: Loader(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: const Column(
                  children: [],
                ),
              ),
            ),
    );
  }
}
