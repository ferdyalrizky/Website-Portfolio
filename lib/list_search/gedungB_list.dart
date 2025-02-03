import 'package:flutter/material.dart';
import 'package:aplikasi_gudang/list_search/barang_gedung/barang_gedungB.dart';
import 'package:aplikasi_gudang/models/rak.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GudangB extends StatefulWidget {
  final String keyword;

  const GudangB(
      {super.key, required this.keyword, required List searchResults});

  @override
  State<GudangB> createState() => _GudangBState();
}

class _GudangBState extends State<GudangB> {
  bool loadingResults = true;
  List<Room> searchResults = [];
  String? _selectedRoom;

  final Map<String, List<Alignment>> roomPositions = {
    "Gudang B": [
      //baris 1
      const Alignment(-0.9, -1.0),
      const Alignment(-0.58, -1.0),
      const Alignment(-0.25, -1.0),
      const Alignment(0.55, -1.0),
      const Alignment(0.9, -1.0),
      // baris 2
      const Alignment(-0.9, -0.4),
      const Alignment(-0.58, -0.4),
      const Alignment(-0.25, -0.4),
      const Alignment(0.55, -0.4),
      const Alignment(0.9, -0.4),
      // baris 3
      const Alignment(-0.9, 0.2),
      const Alignment(-0.58, 0.2),
      const Alignment(-0.25, 0.2),
      const Alignment(0.55, 0.2),
      const Alignment(0.9, 0.2),
      //baris 4
      const Alignment(-0.9, 0.8),
      const Alignment(-0.58, 0.8),
      const Alignment(-0.25, 0.8),
      const Alignment(0.55, 0.8),
      const Alignment(0.9, 0.8),
      //baris 5
      const Alignment(-0.9, 1.4),
      const Alignment(-0.58, 1.4),
      const Alignment(-0.25, 1.4),
      const Alignment(0.55, 1.4),
      const Alignment(0.9, 1.4),
      //baris 6
      const Alignment(-0.9, 2.0),
      const Alignment(-0.58, 2.0),
      const Alignment(-0.25, 2.0),
      const Alignment(0.55, 2.0),
      const Alignment(0.9, 2.0),
      //baris 7
      const Alignment(-0.9, 2.6),
      const Alignment(-0.58, 2.6),
      const Alignment(-0.25, 2.6),
      const Alignment(0.55, 2.6),
      const Alignment(0.9, 2.6),
      //baris 8
      const Alignment(-0.9, 3.2),
      const Alignment(-0.58, 3.2),
      const Alignment(-0.25, 3.2),
      const Alignment(0.55, 3.2),
      const Alignment(0.9, 3.2),
      //baris 9
      const Alignment(-0.9, 3.8),
      const Alignment(-0.58, 3.8),
      const Alignment(-0.25, 3.8),
      const Alignment(0.55, 3.8),
      const Alignment(0.9, 3.8),
      //baris 10
      const Alignment(-0.9, 4.4),
      const Alignment(-0.58, 4.4),
      const Alignment(-0.25, 4.4),
      const Alignment(0.55, 4.4),
      const Alignment(0.9, 4.4),
      //baris 11
      const Alignment(-0.9, 5.0),
      const Alignment(-0.58, 5.0),
      const Alignment(-0.25, 5.0),
      const Alignment(0.55, 5.0),
      const Alignment(0.9, 5.0),
      //baris 12
      const Alignment(-0.9, 5.6),
      const Alignment(-0.58, 5.6),
      const Alignment(-0.25, 5.6),
      const Alignment(0.55, 5.6),
      const Alignment(0.9, 5.6),
      //baris 13
      const Alignment(-0.9, 6.2),
      const Alignment(-0.58, 6.2),
      const Alignment(-0.25, 6.2),
      const Alignment(0.55, 6.2),
      const Alignment(0.9, 6.2),
      //baris 14
      const Alignment(-0.9, 6.8),
      const Alignment(-0.58, 6.8),
      const Alignment(-0.25, 6.8),
      const Alignment(0.55, 6.8),
      const Alignment(0.9, 6.8),
      //baris 15
      const Alignment(-0.9, 7.4),
      const Alignment(-0.58, 7.4),
      const Alignment(-0.25, 7.4),
      const Alignment(0.55, 7.4),
      const Alignment(0.9, 7.4),
      //baris 16
      const Alignment(-0.9, 8.0),
      const Alignment(-0.58, 8.0),
      const Alignment(-0.25, 8.0),
      const Alignment(0.55, 8.0),
      const Alignment(0.9, 8.0),
      //baris 17
      const Alignment(-0.9, 10.8),
      const Alignment(-0.58, 10.8),
      const Alignment(-0.25, 10.8),
      const Alignment(0.55, 10.8),
      const Alignment(0.9, 10.8),
      //baris 18
      const Alignment(-0.9, 11.4),
      const Alignment(-0.58, 11.4),
      const Alignment(-0.25, 11.4),
      const Alignment(0.55, 11.4),
      const Alignment(0.9, 11.4),
      //baris 19
      const Alignment(-0.9, 12.0),
      const Alignment(-0.58, 12.0),
      const Alignment(-0.25, 12.0),
      const Alignment(0.55, 12.0),
      const Alignment(0.9, 12.0),
      //baris 20
      const Alignment(-0.9, 12.6),
      const Alignment(-0.58, 12.6),
      const Alignment(-0.25, 12.6),
      const Alignment(0.55, 12.6),
      const Alignment(0.9, 12.6),
      //baris 21
      const Alignment(-0.9, 13.2),
      const Alignment(-0.58, 13.2),
      const Alignment(-0.25, 13.2),
      const Alignment(0.55, 13.2),
      const Alignment(0.9, 13.2),
      //baris 22
      const Alignment(-0.9, 13.8),
      const Alignment(-0.58, 13.8),
      const Alignment(-0.25, 13.8),
      const Alignment(0.15, 13.8),
      const Alignment(0.55, 13.8),
      const Alignment(0.9, 13.8),
      //baris 23
      const Alignment(-0.9, 14.4),
      const Alignment(-0.58, 14.4),
      const Alignment(-0.25, 14.4),
      const Alignment(0.15, 14.4),
      const Alignment(0.55, 14.4),
      const Alignment(0.9, 14.4),
      //baris 24
      const Alignment(-0.9, 15.0),
      const Alignment(-0.58, 15.0),
      const Alignment(-0.25, 15.0),
      const Alignment(0.15, 15.0),
      const Alignment(0.55, 15.0),
      const Alignment(0.9, 15.0),
    ],
  };

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.keyword);
  }

  Future<void> fetchSearchResults(String keyword) async {
    // Fetch all results (modify this URL if necessary)
    final response = await http.get(Uri.parse(
        'https://erp.fgthlzmmbggrp.com/api/barang/warehouse/layout/B?'));

    print('Fetching data for keyword: $keyword');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('JSON Data: $jsonData'); // Print the JSON data

      // Check if 'data' is present and is a list
      if (jsonData['data'] is List) {
        // Flatten the nested arrays into a single list
        List<Room> allRooms = (jsonData['data'] as List)
            .expand((innerList) =>
                (innerList as List).map((roomJson) => Room.fromJson(roomJson)))
            .toList();

        // Filter results based on the keyword
        searchResults = allRooms.where((room) {
          // Ensure 'code' is accessed correctly and check if it contains the keyword
          return room.code
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase());
        }).toList();

        // Debugging: Print the number of results found
        print('Number of rooms found: ${searchResults.length}');

        setState(() {
          loadingResults = false; // Set loading to false
        });
      } else {
        print('Data is not a list or is missing');
        setState(() {
          loadingResults = false; // Set loading to false
        });
      }
    } else {
      setState(() {
        loadingResults = false; // Set loading to false
      });
      print('Failed to load search results: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Search Results for "${widget.keyword}"'),
      ),
      body: loadingResults
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : searchResults.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          // Handle scaling if needed
                        });
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          height: 1500,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 100),
                                child: SizedBox(
                                  width: 80,
                                  height: 35,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFB31312),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/door.png",
                                          width: 17,
                                        ),
                                        const SizedBox(width: 5),
                                        const Text(
                                          "Pintu",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 1225.w,
                                    height: 200.h,
                                    child: Stack(
                                      children: searchResults
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        if (index >=
                                            roomPositions["Gudang B"]!.length) {
                                          return SizedBox(); // Skip rendering if index exceeds available positions
                                        }
                                        Room room =
                                            entry.value; // Get the Room object
                                        Color backgroundColor = room.isActive
                                            ? Colors.green
                                            : const Color(0xFFAFBFCF);

                                        return Align(
                                          alignment:
                                              roomPositions["Gudang B"]![index],
                                          child: SizedBox(
                                            width: 90,
                                            height: 35,
                                            child: TextButton(
                                              onPressed: () {
                                                print(
                                                    'Navigating to BarangGedungb with room code: ${room.code}');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BarangGedungb(
                                                      keyword: widget.keyword,
                                                      selectedRoom: room.code,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                room.code,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 80, left: 125),
                                    child: Image.asset(
                                        "assets/images/walking.png"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 345),
                                    child: Container(
                                      width: 840,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xFF0277B7),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: 150,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFF0277B7), // Background color
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Rounded corners
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                        "Area Gelaran",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Image.asset(
                                                          "assets/images/area.png",
                                                          width: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "Gudang B",
                                            style: TextStyle(
                                              fontStyle: FontStyle
                                                  .italic, // Italic font style
                                              color: Colors.black, // Text color
                                              fontSize: 35.sp,
                                              fontWeight:
                                                  FontWeight.w500, // Text style
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 80, left: 125),
                                    child: Image.asset(
                                        "assets/images/walking.png"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text("No results found"), // Show message if no results
                ),
    );
  }
}
