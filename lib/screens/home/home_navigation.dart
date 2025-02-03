import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aplikasi_gudang/gedung/gedung.dart';
import 'package:aplikasi_gudang/list_search/gedungB_list.dart';
import 'package:aplikasi_gudang/theme/colors/light_colors.dart';
import 'package:aplikasi_gudang/widgets/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/karyawan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currIndexPage = 0;
  late PageController _pageController;

  Karyawan currUser = Karyawan();
  bool loadingFirstTimeLoad = true;
  bool loadingSearchResults = false;
  List<dynamic> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  Future _setupUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // ... (existing code)
    setState(() {
      loadingFirstTimeLoad = false;
    });
  }

  Future<void> _searchItems(String keyword) async {
    setState(() {
      loadingSearchResults = true; // Show loading indicator
    });

    final response = await http.get(Uri.parse(
        'https://erp.fgthlzmmbggrp.com/api/barang/warehouse/B?keyword=$keyword'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        searchResults =
            jsonData['data']; // Assuming 'data' contains the results
        loadingSearchResults = false; // Hide loading indicator
      });

      // Navigasi ke GudangB dengan hasil pencarian
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GudangB(
            keyword: keyword,
            searchResults: searchResults,
          ),
        ),
      );
    } else {
      setState(() {
        loadingSearchResults = false; // Hide loading indicator
      });
      // Handle error (e.g., show a message)
      print('Failed to load search results: ${response.reasonPhrase}');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/images/logo.svg"),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                                top: 4, bottom: 4, left: 12, right: 16)
                            .r,
                        child: Container(
                          height: 50.h,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF585858)),
                              ),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (value) {
                              _searchItems(value); // Call search on submit
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _searchItems(_searchController
                            .text); // Call search on button press
                      },
                      icon: SvgPicture.asset(
                        "assets/images/scan.svg",
                        width: 60.w,
                        height: 50.h,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 100).r,
                      child: IconButton(
                        onPressed: () {
                          print("Notification button pressed");
                        },
                        icon: Icon(
                          Icons.notifications,
                          color: Color(0xFF585858),
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
                BuildingDropdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
