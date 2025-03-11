import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hris_v2/models/meeting.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/models/gabung_pertemuan.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/list/detail_pertemuan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../../../utils/constant.dart';

class ListPertemuan extends StatelessWidget {
  final List<Meeting> meetings;
  final Karyawan currUser;

  const ListPertemuan({
    super.key,
    required this.meetings,
    required this.currUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        return MeetingCard(meeting: meetings[index], currUser: currUser);
      },
    );
  }
}

class MeetingCard extends StatefulWidget {
  final Meeting meeting;
  final Karyawan currUser;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.currUser,
  });

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<Pertemuan> fetchPertemuan(int id) async {
    print("Token : ${widget.currUser.apiToken}");
    final response = await http.get(
      Uri.parse('$API_URL/rutinitas/pertemuan/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );

    print(
        "Response status: ${response.statusCode}"); // Debugging response status
    print("Response body: ${response.body}"); // Debugging response body

    if (response.statusCode == 200) {
      return Pertemuan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load meeting: ${response.statusCode}');
    }
  }

  void _showMeetingDetails(BuildContext context) async {
    try {
      Pertemuan? meetingDetails = await fetchPertemuan(widget.meeting.id);
      if (meetingDetails == null) {
        _showErrorSnackbar(context, "Meeting details not found.");
        return; // Exit if no details are found
      }

      print("token ini : ${widget.meeting.id}");

      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => DetailPertemuan(
          meetingId: meetingDetails.id,
          currUser: widget.currUser,
        ),
      );
    } catch (e) {
      print("Error fetching meeting details: $e");
      _showErrorSnackbar(context, "Failed to load meeting details.");
    }
  }

  void _showModalBottomSheet(BuildContext context, Pertemuan meetingDetails) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => makeDismissible(
        child: DraggableScrollableSheet(
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
                SizedBox(height: 25.h),
                _buildMeetingDetails(meetingDetails),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingDetails(Pertemuan meetingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, size: 30.w, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        Text(
          meetingDetails.judul,
          style: TextStyle(
              fontSize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 10.h),
        _buildDetailRow("Pembuat", meetingDetails.creator),
        SizedBox(height: 20.h),
        _buildDetailRow("Peserta", getPesertaNames(meetingDetails.peserta)),
        SizedBox(height: 20.h),
        _buildDetailRow("Deskripsi", meetingDetails.deskripsi),
        SizedBox(height: 25.h),
      ],
    );
  }

  Widget _buildDetailRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF585858),
              fontWeight: FontWeight.w400),
        ),
        Text(
          content,
          style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String getPesertaNames(List<Babu>? pesertaList) {
    if (pesertaList == null || pesertaList.isEmpty) {
      return "No participants";
    }
    return pesertaList.map((peserta) => peserta.name).join(", ");
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 14, bottom: 14, left: 17, right: 17).r,
      child: InkWell(
        onTap: () {
          _showMeetingDetails(context); // Call the method to show details
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          color: widget.meeting.typePertemuan == "offline"
              ? Color(0xFFFFFAEA)
              : Color(0xFFE6F1F8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.meeting.judul}',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp),
                      ),
                      SizedBox(height: 8.h),
                      _buildMeetingTimeAndLocation(),
                      SizedBox(height: 10),
                      _buildParticipantsAvatars(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingTimeAndLocation() {
    return Row(
      children: [
        Icon(Icons.access_time, color: Color(0xFF585858), size: 25.w),
        SizedBox(width: 5.w),
        Text(
          "${widget.meeting.jamAwal.split(':')[0]}:${widget.meeting.jamAwal.split(':')[1]} - ${widget.meeting.jamAkhir.split(':')[0]}:${widget.meeting.jamAkhir.split(':')[1]} WIB",
          style: TextStyle(
              color: Color(0xFF585858),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 20.w),
        widget.meeting.typePertemuan == "offline"
            ? Icon(Icons.location_on, color: Color(0xFF585858))
            : SvgPicture.asset("assets/images/online.svg",
                width: 25, color: Color(0xFF585858)),
        SizedBox(width: 5.w),
        Text(
          widget.meeting.typePertemuan == "offline"
              ? widget.meeting.lokasi
              : widget.meeting.typePertemuan,
          style: TextStyle(
              fontSize: 13.sp,
              color: Color(0xFF585858),
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildParticipantsAvatars() {
    // Ambil peserta yang akan ditampilkan
    List<dynamic> participants = widget.meeting.peserta;
    int totalParticipants = participants.length;

    // Ambil peserta pertama hingga keempat
    List<dynamic> firstParticipants =
        totalParticipants > 4 ? participants.sublist(0, 4) : participants;

    return Container(
      height: 40,
      child: Stack(
        children: [
          // Tampilkan avatar peserta
          ...firstParticipants.asMap().entries.map((entry) {
            int index = entry.key;
            var peserta = entry.value;

            return Positioned(
              left: index * 20.0,
              child: CircleAvatar(
                backgroundImage: NetworkImage(peserta.imgUrl),
                radius: 18.r,
                backgroundColor: Colors.grey[200],
              ),
            );
          }).toList(),

          // Tampilkan teks "+X" di atas gambar peserta terakhir jika ada lebih dari 4 peserta
          if (totalParticipants > 4)
            Positioned(
              left: 60.0, // Sesuaikan posisi sesuai kebutuhan
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: NetworkImage(
                        participants[3].imgUrl), // Ambil avatar peserta ke-4
                    backgroundColor: Colors.grey[200],
                  ),
                  ClipOval(
                    child: Container(
                      width: 30, // Diameter lingkaran
                      height: 28, // Diameter lingkaran
                      color: Colors.black.withOpacity(
                          0.2), // Latar belakang gelap dengan transparansi
                      child: Center(
                        child: Text(
                          '+${totalParticipants - 4}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Teks berwarna putih
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );
}
