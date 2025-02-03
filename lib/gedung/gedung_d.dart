import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuildingDPage extends StatefulWidget {
  const BuildingDPage({super.key});

  @override
  State<BuildingDPage> createState() => _BuildingDPageState();
}

class _BuildingDPageState extends State<BuildingDPage> {
  String? _selectedRoom;

  final Map<String, List<String>> buildings = {
    "Gudang D": [
      //kolom 1
      "D601",
      "D602",
      "D603",
      "D604",
      "D605",
      "D606",
      "D607",
      "D608",
      "D609",
      "D610",
      "D611",
      "D612",
      "D613",
      "D614",
      //kolom 2
      "D501",
      "D502",
      "D503",
      "D504",
      "D505",
      "D506",
      "D507",
      "D508",
      "D509",
      "D510",
      "D511",
      "D512",
      "D513",
      "D514",
      //kolom 3
      "D401",
      "D402",
      "D403",
      "D404",
      "D405",
      "D406",
      "D407",
      "D408",
      "D409",
      "D410",
      "D411",
      "D412",
      "D413",
      "D414",
      //kolom 4
      "D301",
      "D302",
      "D303",
      "D304",
      "D305",
      "D306",
      "D307",
      "D308",
      "D309",
      "D310",
      "D311",
      "D312",
      "D313",
      "D314",
      //kolom 5
      "D201",
      "D202",
      "D203",
      "D204",
      "D205",
      "D206",
      "D207",
      "D208",
      "D209",
      "D210",
      "D211",
      "D212",
      "D213",
      "D214",
      //kolom 6
      "D102",
      "D103",
      "D104",
      "D105",
      "D106",
      "D107",
      "D108",
      "D109",
      "D110",
      "D111",
      "D112",
      "D113",
    ],
  };

  final Map<String, List<Alignment>> roomPositions = {
    "Gudang D": [
      //kolom 1
      const Alignment(-0.9, -1.0), //D601
      const Alignment(-0.9, -0.4), //D602
      const Alignment(-0.9, 0.2), //D603
      const Alignment(-0.9, 0.8), //D604
      const Alignment(-0.9, 1.4), //D605
      const Alignment(-0.9, 2.0), //D606
      const Alignment(-0.9, 4.8), //D607
      const Alignment(-0.9, 5.4), //D608
      const Alignment(-0.9, 6.0), //D609
      const Alignment(-0.9, 6.6), //D610
      const Alignment(-0.9, 7.2), //D611
      const Alignment(-0.9, 7.8), //D612
      const Alignment(-0.9, 8.4), //D613
      const Alignment(-0.9, 9.0), //D614
      //kolom 2
      const Alignment(-0.6, -1.0), //D501
      const Alignment(-0.6, -0.4), //D502
      const Alignment(-0.6, 0.2), //D503
      const Alignment(-0.6, 0.8), //D504
      const Alignment(-0.6, 1.4), //D505
      const Alignment(-0.6, 2.0), //D506
      const Alignment(-0.6, 4.8), //D507
      const Alignment(-0.6, 5.4), //D508
      const Alignment(-0.6, 6.0), //D509
      const Alignment(-0.6, 6.6), //D510
      const Alignment(-0.6, 7.2), //D511
      const Alignment(-0.6, 7.8), //D512
      const Alignment(-0.6, 8.4), //D513
      const Alignment(-0.6, 9.0), //D514
      //kolom 3
      const Alignment(-0.3, -1.0), //D401
      const Alignment(-0.3, -0.4), //D402
      const Alignment(-0.3, 0.2), //D403
      const Alignment(-0.3, 0.8), //D404
      const Alignment(-0.3, 1.4), //D405
      const Alignment(-0.3, 2.0), //D406
      const Alignment(-0.3, 4.8), //D407
      const Alignment(-0.3, 5.4), //D408
      const Alignment(-0.3, 6.0), //D409
      const Alignment(-0.3, 6.6), //D410
      const Alignment(-0.3, 7.2), //D411
      const Alignment(-0.3, 7.8), //D412
      const Alignment(-0.3, 8.4), //D413
      const Alignment(-0.3, 9.0), //D414
      //Kolom 4
      const Alignment(0.3, -1.0), //D301
      const Alignment(0.3, -0.4), //D302
      const Alignment(0.3, 0.2), //D303
      const Alignment(0.3, 0.8), //D304
      const Alignment(0.3, 1.4), //D305
      const Alignment(0.3, 2.0), //D306
      const Alignment(0.3, 4.8), //D307
      const Alignment(0.3, 5.4), //D308
      const Alignment(0.3, 6.0), //D309
      const Alignment(0.3, 6.6), //D310
      const Alignment(0.3, 7.2), //D311
      const Alignment(0.3, 7.8), //D312
      const Alignment(0.3, 8.4), //D313
      const Alignment(0.3, 9.0), //D314
      //kolom 5
      const Alignment(0.6, -1.0), //D201
      const Alignment(0.6, -0.4), //D202
      const Alignment(0.6, 0.2), //D203
      const Alignment(0.6, 0.8), //D204
      const Alignment(0.6, 1.4), //D205
      const Alignment(0.6, 2.0), //D206
      const Alignment(0.6, 4.8), //D207
      const Alignment(0.6, 5.4), //D208
      const Alignment(0.6, 6.0), //D209
      const Alignment(0.6, 6.6), //D210
      const Alignment(0.6, 7.2), //D211
      const Alignment(0.6, 7.8), //D212
      const Alignment(0.6, 8.4), //D213
      const Alignment(0.6, 9.0), //D214
      //kolom 6
      const Alignment(0.9, -0.4), //D102
      const Alignment(0.9, 0.2), //D103
      const Alignment(0.9, 0.8), //D104
      const Alignment(0.9, 1.4), //D105
      const Alignment(0.9, 2.0), //D106
      const Alignment(0.9, 4.8), //D107
      const Alignment(0.9, 5.4), //D108
      const Alignment(0.9, 6.0), //D109
      const Alignment(0.9, 6.6), //D110
      const Alignment(0.9, 7.2), //D111
      const Alignment(0.9, 7.8), //D112
      const Alignment(0.9, 8.4), //D113
    ],
  };

  final Map<String, Color> _roomColors = {
    "D510": Colors.green,
    "D502": Colors.green,
    "D505": Colors.green,
    "D408": Colors.green,
    "D301": Colors.green,
    "D205": Colors.green,
    "D212": Colors.green,
    "D113": Colors.green,
    "D104": Colors.green,
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 1225.w,
                        height: 200.h,
                        child: Stack(
                          children: buildings["Gudang D"]!
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            String room = entry.value;
                            return Align(
                              alignment: roomPositions["Gudang D"]![index],
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
                                    backgroundColor: _roomColors[room] ??
                                        const Color(
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Image.asset("assets/images/walking.png"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 50,
                        ),
                        child: Container(
                          width: 840,
                          height: 150,
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
                                      width: 150,
                                      height: 25,
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Image.asset(
                                            "assets/images/area.png",
                                            width: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Gudang D",
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
                      Padding(
                        padding: const EdgeInsets.only(top: 80, left: 10),
                        child: Image.asset("assets/images/walking.png"),
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
