import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildingCPage extends StatefulWidget {
  const BuildingCPage({super.key});

  @override
  State<BuildingCPage> createState() => _BuildingCPageState();
}

class _BuildingCPageState extends State<BuildingCPage> {
  String? _selectedRoom;
  double _scaleFactor = 1.0;

  final Map<String, List<String>> buildings = {
    "Gudang C": [
      //kolom 1
      "C601",
      "C602",
      "C603",
      "C604",
      "C605",
      "C606",
      "C607",
      "C608",
      "C609",
      "C610",
      "C611",
      "C612",
      "C613",
      "C614",
      "C615",
      "C616",
      "C617",
      "C618",
      "C619",
      "C620",
      "C621",
      "C622",
      "C623",
      "C624",
      //kolom 2
      "C501",
      "C502",
      "C503",
      "C504",
      "C505",
      "C506",
      "C507",
      "C508",
      "C509",
      "C510",
      "C511",
      "C512",
      "C513",
      "C514",
      "C515",
      "C516",
      "C517",
      "C518",
      "C519",
      "C520",
      "C521",
      "C522",
      "C523",
      "C524",
      //kolom 3
      "C401",
      "C402",
      "C403",
      "C404",
      "C405",
      "C406",
      "C407",
      "C408",
      "C409",
      "C410",
      "C411",
      "C412",
      "C413",
      "C414",
      "C415",
      "C416",
      "C417",
      "C418",
      "C419",
      "C420",
      "C421",
      "C422",
      "C423",
      "C424",
      //kolom 4
      "C301",
      "C302",
      "C303",
      "C304",
      "C305",
      "C306",
      "C307",
      "C308",
      "C309",
      "C310",
      "C311",
      "C312",
      "C313",
      "C314",
      "C315",
      "C316",
      "C317",
      "C318",
      "C319",
      "C320",
      "C321",
      "C322",
      "C323",
      "C324",
      //kolom 5
      "C201",
      "C202",
      "C203",
      "C204",
      "C205",
      "C206",
      "C207",
      "C208",
      "C209",
      "C210",
      "C211",
      "C212",
      "C213",
      "C214",
      "C215",
      "C216",
      "C217",
      "C218",
      "C219",
      "C220",
      "C221",
      "C222",
      "C223",
      "C224",
      //kolom 6
      "C101",
      "C102",
      "C103",
      "C104",
      "C105",
      "C106",
      "C107",
      "C108",
      "C109",
      "C110",
      "C111",
      "C112",
      "C113",
      "C114",
      "C115",
      "C116",
      "C117",
      "C118",
      "C119",
      "C120",
      "C121",
      "C122",
      "C123",
      "C124",
    ],
  };

  final Map<String, List<Alignment>> roomPositions = {
    "Gudang C": [
      //baris 1
      const Alignment(-0.9, -1.0),
      const Alignment(-0.6, -1.0),
      const Alignment(-0.3, -1.0),
      const Alignment(0.3, -1.0),
      const Alignment(0.6, -1.0),
      const Alignment(0.9, -1.0),

      //baris 2
      const Alignment(-0.9, -0.4),
      const Alignment(-0.6, -0.4),
      const Alignment(-0.3, -0.4),
      const Alignment(0.3, -0.4),
      const Alignment(0.6, -0.4),
      const Alignment(0.9, -0.4),

      //baris 3
      const Alignment(-0.9, 0.2),
      const Alignment(-0.6, 0.2),
      const Alignment(-0.3, 0.2),
      const Alignment(0.3, 0.2),
      const Alignment(0.6, 0.2),
      const Alignment(0.9, 0.2),

      //baris 4
      const Alignment(-0.9, 0.8),
      const Alignment(-0.6, 0.8),
      const Alignment(-0.3, 0.8),
      const Alignment(0.3, 0.8),
      const Alignment(0.6, 0.8),
      const Alignment(0.9, 0.8),

      //baris 5
      const Alignment(-0.9, 1.4),
      const Alignment(-0.6, 1.4),
      const Alignment(-0.3, 1.4),
      const Alignment(0.3, 1.4),
      const Alignment(0.6, 1.4),
      const Alignment(0.9, 1.4),

      //baris 6
      const Alignment(-0.9, 2.0),
      const Alignment(-0.6, 2.0),
      const Alignment(-0.3, 2.0),
      const Alignment(0.3, 2.0),
      const Alignment(0.6, 2.0),
      const Alignment(0.9, 2.0),

      // baris 7
      const Alignment(-0.9, 2.6),
      const Alignment(-0.6, 2.6),
      const Alignment(-0.3, 2.6),
      const Alignment(0.3, 2.6),
      const Alignment(0.6, 2.6),
      const Alignment(0.9, 2.6),

      //baris 8
      const Alignment(-0.9, 3.2),
      const Alignment(-0.6, 3.2),
      const Alignment(-0.3, 3.2),
      const Alignment(0.3, 3.2),
      const Alignment(0.6, 3.2),
      const Alignment(0.9, 3.2),

      //baris 9
      const Alignment(-0.9, 3.8),
      const Alignment(-0.6, 3.8),
      const Alignment(-0.3, 3.8),
      const Alignment(0.3, 3.8),
      const Alignment(0.6, 3.8),
      const Alignment(0.9, 3.8),

      //baris 10
      const Alignment(-0.9, 4.4),
      const Alignment(-0.6, 4.4),
      const Alignment(-0.3, 4.4),
      const Alignment(0.3, 4.4),
      const Alignment(0.6, 4.4),
      const Alignment(0.9, 4.4),

      //baris 11
      const Alignment(-0.9, 5.0),
      const Alignment(-0.6, 5.0),
      const Alignment(-0.3, 5.0),
      const Alignment(0.3, 5.0),
      const Alignment(0.6, 5.0),
      const Alignment(0.9, 5.0),

      //baris 12
      const Alignment(-0.9, 5.6),
      const Alignment(-0.6, 5.6),
      const Alignment(-0.3, 5.6),
      const Alignment(0.3, 5.6),
      const Alignment(0.6, 5.6),
      const Alignment(0.9, 5.6),

      //baris 13
      const Alignment(-0.9, 6.2),
      const Alignment(-0.6, 6.2),
      const Alignment(-0.3, 6.2),
      const Alignment(0.3, 6.2),
      const Alignment(0.6, 6.2),
      const Alignment(0.9, 6.2),

      //baris 14
      const Alignment(-0.9, 6.8),
      const Alignment(-0.6, 6.8),
      const Alignment(-0.3, 6.8),
      const Alignment(0.3, 6.8),
      const Alignment(0.6, 6.8),
      const Alignment(0.9, 6.8),

      //baris 15
      const Alignment(-0.9, 7.4),
      const Alignment(-0.6, 7.4),
      const Alignment(-0.3, 7.4),
      const Alignment(0.3, 7.4),
      const Alignment(0.6, 7.4),
      const Alignment(0.9, 7.4),

      //baris 16
      const Alignment(-0.9, 8.0),
      const Alignment(-0.6, 8.0),
      const Alignment(-0.3, 8.0),
      const Alignment(0.3, 8.0),
      const Alignment(0.6, 8.0),
      const Alignment(0.9, 8.0),

      // baris 17
      const Alignment(-0.9, 10.8),
      const Alignment(-0.6, 10.8),
      const Alignment(-0.3, 10.8),
      const Alignment(0.3, 10.8),
      const Alignment(0.6, 10.8),
      const Alignment(0.9, 10.8),

      //baris 18
      const Alignment(-0.9, 11.4),
      const Alignment(-0.6, 11.4),
      const Alignment(-0.3, 11.4),
      const Alignment(0.3, 11.4),
      const Alignment(0.6, 11.4),
      const Alignment(0.9, 11.4),

      //baris 19
      const Alignment(-0.9, 12.0),
      const Alignment(-0.6, 12.0),
      const Alignment(-0.3, 12.0),
      const Alignment(0.3, 12.0),
      const Alignment(0.6, 12.0),
      const Alignment(0.9, 12.0),

      //baris 20
      const Alignment(-0.9, 12.6),
      const Alignment(-0.6, 12.6),
      const Alignment(-0.3, 12.6),
      const Alignment(0.3, 12.6),
      const Alignment(0.6, 12.6),
      const Alignment(0.9, 12.6),

      //baris 21
      const Alignment(-0.9, 13.2),
      const Alignment(-0.6, 13.2),
      const Alignment(-0.3, 13.2),
      const Alignment(0.3, 13.2),
      const Alignment(0.6, 13.2),
      const Alignment(0.9, 13.2),

      //baris 22
      const Alignment(-0.9, 13.8),
      const Alignment(-0.6, 13.8),
      const Alignment(-0.3, 13.8),
      const Alignment(0.3, 13.8),
      const Alignment(0.6, 13.8),
      const Alignment(0.9, 13.8),

      //baris 23
      const Alignment(-0.9, 14.4),
      const Alignment(-0.6, 14.4),
      const Alignment(-0.3, 14.4),
      const Alignment(0.3, 14.4),
      const Alignment(0.6, 14.4),
      const Alignment(0.9, 14.4),

      //baris 24
      const Alignment(-0.9, 15.0),
      const Alignment(-0.6, 15.0),
      const Alignment(-0.3, 15.0),
      const Alignment(0.3, 15.0),
      const Alignment(0.6, 15.0),
      const Alignment(0.9, 15.0),
    ],
  };

  final Map<String, Color> _roomColors = {
    "C510": Colors.green,
    "C502": Colors.green,
    "C505": Colors.green,
    "C408": Colors.green,
    "C417": Colors.green,
    "C301": Colors.green,
    "C205": Colors.green,
    "C212": Colors.green,
    "C220": Colors.green,
    "C124": Colors.green,
    "C113": Colors.green,
    "C104": Colors.green,
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
            onScaleUpdate: (details) {
              setState(() {
                _scaleFactor = details.scale.clamp(1.0, 3.0);
              });
            },
            child: Transform.scale(
              scale: _scaleFactor,
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: 1225.w,
                          height: 200.h,
                          child: Stack(
                            children: buildings["Gudang C"]!
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              String room = entry.value;
                              return Align(
                                alignment: roomPositions["Gudang C"]![index],
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
                          padding: const EdgeInsets.only(top: 80, left: 10),
                          child: Image.asset("assets/images/walking.png"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 345,
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
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                  "Gudang C",
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
          ),
        ],
      ),
    );
  }
}
