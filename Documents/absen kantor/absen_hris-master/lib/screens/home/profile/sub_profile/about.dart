import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool isLoading = true;
  String appName = "Fagetti ESS";
  String? version;

  getApplicationInformation() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version + (Platform.isIOS ? " iOS" : " Android");
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getApplicationInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: const [],
      ),
      body: isLoading
          ? const Center(
              child: Loader(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: subheading("Tentang Aplikasi"),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: subheading1("Nama Tim Pengembang"),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: subtitle("IT Infrastruktur"),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: subheading1("Maksud & Tujuan Pembuatan Aplikasi"),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: subtitle1(
                        "Pembuatan aplikasi bertujuan untuk memberikan solusi digital yang efektif dan efisien bagi karyawan fagetti dalam absensi, perijinan dan kebutuhan yang lain serta penambahan fitur baru yakni, rutinitas,klaim biaya dan penilaian. Aplikasi ini dirancang untuk meningkatkan produktivitas, mempercepat proses, dan memudahkan akses informasi secara cepat dan akurat. Selain itu, aplikasi ini juga diharapkan dapat memberikan pengalaman yang menyenangkan melalui tampilan antarmuka yang user-friendly, membantu pengguna mencapai hasil yang diinginkan dengan lebih nyaman. Dengan adanya aplikasi ini, diharapkan proses yang sebelumnya memakan waktu dapat dilakukan dengan lebih mudah, sehingga memberikan nilai tambah dan manfaat bagi penggunanya.",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: subheading1("Versi Aplikasi"),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: subtitle(version!),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.sp,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Text subheading1(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Text subtitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Text subtitle1(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
