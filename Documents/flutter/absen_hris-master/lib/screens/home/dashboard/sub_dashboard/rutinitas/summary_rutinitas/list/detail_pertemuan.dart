import 'package:flutter/material.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

class DetailPertemuan extends StatelessWidget {
  final int meetingId; // ID pertemuan
  final Karyawan currUser;

  const DetailPertemuan({
    Key? key,
    required this.meetingId,
    required this.currUser,
  }) : super(key: key);

  Future<Pertemuan> fetchPertemuan(int id) async {
    final response = await http.get(
      Uri.parse('$API_URL/rutinitas/pertemuan/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${currUser.apiToken}',
      },
    );

    if (response.statusCode == 200) {
      return Pertemuan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load meeting: ${response.statusCode}');
    }
  }

  Future<void> joinGoogleMeet(String meetLink) async {
    Uri url = Uri.parse(meetLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $meetLink');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pertemuan>(
      future: fetchPertemuan(meetingId), // Ambil data berdasarkan ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data found'));
        }

        final Pertemuan meeting = snapshot.data!;
        print("Meeting link: ${meeting.linkPertemuan}");
        return DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 1,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
            child: ListView(
              controller: controller,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            iconSize: 30,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                iconSize: 30,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFB31312),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              IconButton(
                                iconSize: 30,
                                icon: const Icon(
                                  Icons.border_color_outlined,
                                  color: Color(0xFF0277B7),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        meeting.judul,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${meeting.id}",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      _buildRow("Pembuat", "${meeting.creator}"),
                      _buildRow("Tipe pertemuan", "${meeting.typePertemuan}"),
                      if (meeting.typePertemuan == "offline") ...[
                        _buildRow("Lokasi", "${meeting.lokasi}"),
                        _buildRow("Detail lokasi", "${meeting.detailLokasi}"),
                      ],
                      _buildParticipantsRow(meeting.peserta),
                      _buildRow("Tanggal pertemuan", "${meeting.tglPertemuan}"),
                      _buildRow("Jam",
                          "${formatJam(meeting.jamAwal)} - ${formatJam(meeting.jamAkhir)}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140.w,
                            child: Text(
                              "Link pertemuan",
                              style: TextStyle(
                                color: Color(0xFF585858),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                joinGoogleMeet("${meeting.linkPertemuan}");
                              },
                              child: Text(
                                meeting.linkPertemuan,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                  fontSize: 16.sp,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Menambahkan overflow
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text("Deskripsi pertemuan",
                          style: TextStyle(
                            color: Color(0xFF585858),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          )),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(meeting.deskripsi,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text("File pendukung",
                          style: TextStyle(
                            color: Color(0xFF585858),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          )),
                      InkWell(
                        onTap: () {
                          joinGoogleMeet("${meeting.linkPendukung}");
                        },
                        child: Text(
                          meeting.linkPendukung,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                            fontSize: 16.sp,
                            decoration: TextDecoration.underline,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Menambahkan overflow
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatJam(String jam) {
    // Memastikan jam tidak null dan memiliki panjang yang cukup
    if (jam != null && jam.length >= 5) {
      return jam.substring(0, 5); // Mengambil substring dari indeks 0 sampai 5
    }
    return jam; // Kembalikan jam asli jika tidak valid
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 140.w,
                  child: Text(title,
                      style: TextStyle(
                        color: Color(0xFF585858),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ))),
              Expanded(
                  child: Text(value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16.sp,
                      ))),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
        ],
      ),
    );
  }

  Widget _LinkRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140.w,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF585858),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final Uri url =
                        Uri.parse(value); // Mengubah string menjadi Uri
                    print("Link tapped: $url");
                    if (await canLaunchUrl(url)) {
                      // Menggunakan canLaunchUrl
                      await launchUrl(url,
                          mode: LaunchMode
                              .externalApplication); // Menggunakan launchUrl dengan mode
                    } else {
                      print('Could not launch $url');
                    }
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      fontSize: 16.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsRow(List<Babu> peserta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text("Peserta",
                style: TextStyle(
                  color: Color(0xFF585858),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                )),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: peserta.map((babu) {
                IconData? icon;
                Color? iconColor;
                if (babu.attendance == null) {
                  icon = null;
                } else if (babu.attendance == false) {
                  icon = Icons.close;
                  iconColor = Colors.red;
                } else if (babu.attendance == true) {
                  icon = Icons.check;
                  iconColor = Colors.green;
                }
                return _participantItem(babu.name, icon, iconColor);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create participant rows
  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _participantItem(String name, IconData? icon, Color? iconColor) {
    // Capitalize the name
    String formattedName = capitalizeWords(name);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(formattedName,
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (icon != null) Icon(icon, color: iconColor),
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
