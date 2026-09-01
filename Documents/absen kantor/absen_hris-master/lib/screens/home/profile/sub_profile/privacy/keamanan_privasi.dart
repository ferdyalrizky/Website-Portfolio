import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/theme/colors/text_style.dart';

class KeamananPrivasi extends StatefulWidget {
  const KeamananPrivasi({super.key});

  @override
  State<KeamananPrivasi> createState() => _KeamananPrivasiState();
}

class _KeamananPrivasiState extends State<KeamananPrivasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keamanan Privasi",
                  style: CustomTextStyle.title,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Di Fagetti ESS, kami berkomitmen untuk melindungi privasi Anda. Kebijakan Privasi ini menguraikan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda ketika Anda menggunakan aplikasi kami.",
                  style: CustomTextStyle.subtitle,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Color(0xFFDBDBDB),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  "1. Informasi yang Kami Kumpulkan",
                  style: CustomTextStyle.subheading,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23).r,
                  child: Column(
                    children: [
                      Text(
                        'Kami dapat mengumpulkan jenis informasi berikut ketika Anda menggunakan aplikasi kami:',
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Informasi Pribadi: Saat Anda membuat akun, kami mengumpulkan informasi pribadi seperti nama, alamat email, nomor telepon, dan informasi lain yang Anda berikan.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Data Penggunaan: Kami mengumpulkan data tentang cara Anda berinteraksi dengan aplikasi, termasuk halaman yang dilihat, fitur yang digunakan, dan waktu yang dihabiskan untuk menggunakan aplikasi.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Informasi Perangkat: Kami mengumpulkan informasi tentang perangkat yang Anda gunakan, termasuk model perangkat keras, sistem operasi, pengidentifikasi perangkat unik, dan informasi jaringan seluler.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Data Lokasi: Dengan persetujuan Anda, kami dapat mengumpulkan data lokasi Anda untuk menyediakan layanan berbasis lokasi.",
                        style: CustomTextStyle.subtitle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Color(0xFFDBDBDB),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  "2. Cara Kami Menggunakan Informasi Anda",
                  style: CustomTextStyle.subheading,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23).r,
                  child: Column(
                    children: [
                      Text(
                        'Kami menggunakan informasi yang dikumpulkan untuk:',
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Menyediakan dan meningkatkan fungsionalitas aplikasi.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Mempersonalisasi pengalaman Anda dan mengirimkan konten yang disesuaikan dengan preferensi Anda.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Berkomunikasi dengan Anda mengenai pembaruan dan fitur.",
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        "Menganalisis perilaku pengguna untuk meningkatkan layanan kami.",
                        style: CustomTextStyle.subtitle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Color(0xFFDBDBDB),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  "3. Keamanan Data",
                  style: CustomTextStyle.subheading,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23).r,
                  child: Column(
                    children: [
                      Text(
                        'Kami mengambil langkah-langkah keamanan yang tepat untuk melindungi data pribadi Anda dari akses, perubahan, atau pengungkapan yang tidak sah. Data Anda dienkripsi saat pengiriman dan saat tidak digunakan. Namun demikian, tidak ada metode transmisi atau penyimpanan elektronik yang 100% aman, dan kami tidak dapat menjamin keamanan mutlak.',
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Color(0xFFDBDBDB),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  "4. Hubungi Kami",
                  style: CustomTextStyle.subheading,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini atau bagaimana data Anda ditangani, silakan hubungi kami di:',
                        style: CustomTextStyle.subtitle,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text("Email: it@fagetti.com")
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
}
