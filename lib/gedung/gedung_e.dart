import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildingEPage extends StatefulWidget {
  const BuildingEPage({super.key});

  @override
  State<BuildingEPage> createState() => _BuildingEPageState();
}

class _BuildingEPageState extends State<BuildingEPage> {
  String? _selectedRoom;

  final Map<String, List<String>> buildings = {
    "Gudang E": [
      //kolom 1
      "E101",
      "E201",
      "E301",

      //kolom 2
      "E102",
      "E202",
      "E302",
      "E402",
      "E502",
      "E602",
      "E702",
      "E802",

      //kolom 3
      "E103",
      "E203",
      "E303",
      "E403",
      "E503",
      "E603",
      "E703",
      "E803",
    ],
  };

  final Map<String, List<Alignment>> roomPositions = {
    "Gudang E": [
      //kolom 1
      const Alignment(0.0, -5.76),
      const Alignment(-0.3, -5.76),
      const Alignment(-0.6, -5.76),

      //kolom 2
      const Alignment(0.0, 4.5),
      const Alignment(-0.3, 4.5),
      const Alignment(-0.6, 4.5),
      const Alignment(-0.9, 4.5),
      const Alignment(-1.2, 4.5),
      const Alignment(-1.5, 4.5),
      const Alignment(-1.8, 4.5),
      const Alignment(-2.1, 4.5),
      //kolom 3
      const Alignment(0.0, 5.76),
      const Alignment(-0.3, 5.76),
      const Alignment(-0.6, 5.76),
      const Alignment(-0.9, 5.76),
      const Alignment(-1.2, 5.76),
      const Alignment(-1.5, 5.76),
      const Alignment(-1.8, 5.76),
      const Alignment(-2.1, 5.76),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 280),
                  child: SizedBox(
                    width: 80,
                    height: 35,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Color(0xFFB31312), // Gunakan warna yang sesuai
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
                          const SizedBox(
                            width: 5,
                          ),
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: -math.pi / 2,
                        child: Container(
                          width: 1225.w,
                          height: 200.h,
                          child: Stack(
                            children: buildings["Gudang E"]!
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              String room = entry.value;
                              return Align(
                                alignment: roomPositions["Gudang E"]![index],
                                child: SizedBox(
                                  width: 90,
                                  height: 35,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedRoom =
                                            room; // Simpan ruangan yang dipilih
                                      });
                                      // Tambahkan print untuk debugging
                                      print("Selected Room: $_selectedRoom");
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(
                                          0xFFAFBFCF), // Gunakan warna yang sesuai
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      room,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 280, bottom: 4),
                        child: Image.asset("assets/images/walking.png"),
                      ),
                      Row(
                        children: [
                          // Container yang sudah ada
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 152,
                                right: 100), // Atur padding atas dan kanan
                            child: Container(
                              width: 350,
                              height: 700,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFF0277B7), width: 1),
                                borderRadius:
                                    BorderRadius.circular(10), // Radius sudut
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 135,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFF0277B7), // Background color
                                            borderRadius: BorderRadius.circular(
                                                8), // Set the circular radius
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Area Gelaran",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(width: 5),
                                              Image.asset(
                                                "assets/images/area.png",
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 305),
                                  Text(
                                    "Gudang E",
                                    style: TextStyle(
                                      fontStyle: FontStyle
                                          .italic, // Set fontStyle to italic
                                      color: Colors.black, // Warna teks
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.w500, // Gaya teks
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Gambar di tengah secara vertikal
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10), // Atur padding sesuai kebutuhan
                            child: Image.asset("assets/images/walking.png"),
                          ),
                          SizedBox(
                            width: 310,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
