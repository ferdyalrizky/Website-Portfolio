import 'package:flutter/material.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    String? token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('http://162.5.10.107/app_project/api/rutinitas/pertemuan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Pertemuan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load meeting: ${response.statusCode}');
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

        return DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 1,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
            padding: const EdgeInsets.all(16).w,
            child: ListView(
              controller: controller,
              children: [
                Text(meeting.judul), // Tampilkan judul
                Text(meeting.creator), // Tampilkan creator
                // Tambahkan elemen lain sesuai kebutuhan
              ],
            ),
          ),
        );
      },
    );
  }
}
