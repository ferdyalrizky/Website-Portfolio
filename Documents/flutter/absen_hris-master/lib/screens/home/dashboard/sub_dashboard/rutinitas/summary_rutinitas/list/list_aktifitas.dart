import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/aktifitas.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../utils/constant.dart';

class AktifitasCard extends StatefulWidget {
  final Aktifitas aktifitas;
  final Karyawan currUser;

  const AktifitasCard({
    super.key,
    required this.aktifitas,
    required this.currUser,
  });

  @override
  State<AktifitasCard> createState() => _AktifitasCardState();
}

class _AktifitasCardState extends State<AktifitasCard> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF585858),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16.sp,
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

  Future<void> joinGoogleMeet(String meetLink) async {
    Uri url = Uri.parse(meetLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $meetLink');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 14, bottom: 14, left: 17, right: 17).r,
      child: InkWell(
        onTap: () {
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                  padding: const EdgeInsets.all(16).w,
                  child: ListView(
                    controller: controller,
                    children: [
                      SizedBox(height: 30.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            widget.aktifitas.judulTodo,
                            style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 25.h),
                          _buildRow("Durasi tugas",
                              "${DateFormat('dd MMM yyyy').format(widget.aktifitas.tglMulai)} - ${DateFormat('dd MMM yyyy').format(widget.aktifitas.tglSelesai)}"),
                          SizedBox(height: 15.h),
                          Text(
                            "Link file Pendukung",
                            style: TextStyle(
                              color: Color(0xFF585858),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              joinGoogleMeet(
                                  "${widget.aktifitas.linkPendukung}");
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    "${widget.aktifitas.linkPendukung}",
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
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "File Pendukung",
                            style: TextStyle(
                              color: Color(0xFF585858),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.file_copy_outlined,
                                color: Colors.black54,
                                size: 18.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "filependukung.pdf",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    barrierColor: Colors.black87,
                                    transitionDuration:
                                        const Duration(milliseconds: 20),
                                    pageBuilder: (BuildContext buildContext,
                                        Animation animation,
                                        Animation secondaryAnimation) {
                                      return Center(
                                        child: SizedBox(
                                          height: 350.h,
                                          width: 380.w,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '$API_URL_IMAGE/${widget.aktifitas.foto}',
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                // shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const SizedBox(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error),
                                                Text(
                                                    "404 Image Not Found\nPlease Contact Us")
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  "Lihat",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF0277B7),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "Deskripsi tugas",
                            style: TextStyle(
                              color: Color(0xFF585858),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.aktifitas.descTodo,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          color: Color(0xFFE6F1F8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 12),
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
                        widget.aktifitas.judulTodo,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'sampai ${DateFormat('dd MMMM yyyy').format(widget.aktifitas.tglSelesai)}',
                        style: TextStyle(
                          color: Color(0xFF585858),
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.border_color_outlined,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
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
