import 'package:flutter/material.dart';
import 'package:aplikasi_gudang/models/product.dart'; // Make sure to import the Product model
import 'package:aplikasi_gudang/theme/colors/light_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarangGedungb extends StatefulWidget {
  final String keyword; // Parameter for the search keyword
  final String selectedRoom; // Parameter for the selected room code

  const BarangGedungb({
    super.key,
    required this.keyword,
    required this.selectedRoom,
  });

  @override
  State<BarangGedungb> createState() => _BarangGedungbState();
}

class _BarangGedungbState extends State<BarangGedungb> {
  bool loadingResults = true;
  List<Product> searchResults = [];
  List<bool> isOpenList = []; // Daftar untuk menyimpan status setiap kartu

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.selectedRoom);
  }

  Future<void> fetchSearchResults(String selectedRoom) async {
    final response = await http.get(Uri.parse(
        'https://erp.fgthlzmmbggrp.com/api/warehouse/produts-lists?code=$selectedRoom'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['data'] is List) {
        searchResults = (jsonData['data'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        print('Jumlah item: ${searchResults.length}');

        isOpenList = List<bool>.filled(searchResults.length, false);

        setState(() {
          loadingResults = false;
        });
      } else {
        setState(() {
          loadingResults = false;
        });
      }
    } else {
      setState(() {
        loadingResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Selected Room: "${widget.selectedRoom}"'),
      ),
      body: loadingResults
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 10,
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
                shrinkWrap:
                    true, // Allow the GridView to take only the space it needs
                children: List.generate(
                  searchResults.length,
                  (index) {
                    final product = searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Color.fromARGB(255, 148, 144, 144),
                                width: 1,
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              color: Colors.white,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isOpenList[index] =
                                                !isOpenList[index];
                                          });
                                        },
                                        child: Container(
                                          width: 200.w,
                                          height: 200.h,
                                          child: const Card(
                                            color: Color.fromARGB(
                                                255, 188, 185, 185),
                                            child: Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 55,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                          flex: 0, child: SizedBox(width: 1)),
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 40, left: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Nama Barang',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF585858),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 15.sp),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: Text(
                                                      '${product.namaBarang}',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 20.sp),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Barcode",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF585858),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 15.sp),
                                                  ),
                                                  Text(
                                                    "${product.barcode}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 20.sp),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isOpenList[index]) ...[
                                        Text(
                                            'Jam Keluar Kantor : ${product.p}'),
                                        Text('Jam Masuk Kantor : ${product.l}'),
                                        Text('Jam Masuk Kantor : ${product.l}'),
                                      ],
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isOpenList[index] = !isOpenList[
                                                index]; // Toggle status untuk produk ini
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: LightColors.kFagettiBlue,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                isOpenList[index]
                                                    ? "Show less"
                                                    : "Selengkapnya",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Transform.rotate(
                                                angle: isOpenList[index]
                                                    ? 180 * math.pi / 180
                                                    : 0,
                                                child: const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
