import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aplikasi_gudang/gedung/gedung_b.dart';
import 'package:aplikasi_gudang/gedung/gedung_c.dart';
import 'package:aplikasi_gudang/gedung/gedung_d.dart';
import 'package:aplikasi_gudang/gedung/gedung_e.dart';
import 'package:aplikasi_gudang/gedung/gedung_f.dart';

class BuildingDropdown extends StatefulWidget {
  @override
  _BuildingDropdownState createState() => _BuildingDropdownState();
}

class _BuildingDropdownState extends State<BuildingDropdown> {
  String? _selectedRoom;
  String? _selectedBuilding = "Gudang B"; // Initialize with Gedung B

  final Map<String, Widget> buildingPages = {
    "Gudang B": const BuildingBPage(
      keyword: '',
    ),
    "Gudang C": const BuildingCPage(),
    "Gudang D": const BuildingDPage(),
    "Gudang E": const BuildingEPage(),
    "Gudang F": const BuildingFPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 1225.w,
            height: 1500.h,
            color: Colors.white,
            child: Column(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedBuilding = value;
                    });
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBuilding ?? 'Select Building',
                            style: TextStyle(fontSize: 30.sp),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ],
                  ),
                  itemBuilder: (BuildContext context) {
                    return buildingPages.keys.map((String building) {
                      return PopupMenuItem<String>(
                        value: building,
                        child: Text(
                          building,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    }).toList();
                  },
                  offset: const Offset(0, 40),
                ),
                Expanded(
                  child: buildingPages[_selectedBuilding] ?? Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
