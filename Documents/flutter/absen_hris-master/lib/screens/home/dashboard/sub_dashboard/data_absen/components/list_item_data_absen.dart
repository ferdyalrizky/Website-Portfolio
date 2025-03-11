import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/data_absen.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:intl/intl.dart';

import '../../../../../../models/karyawan.dart';

bool isOpen = false;

class ListItemDataAbsen extends StatefulWidget {
  final DataAbsen absen;
  final Karyawan currUser;
  const ListItemDataAbsen(
      {super.key, required this.absen, required this.currUser});

  @override
  State<ListItemDataAbsen> createState() => _ListItemDataAbsenState();
}

class _ListItemDataAbsenState extends State<ListItemDataAbsen> {
  @override
  Widget build(BuildContext context) {
    //Status Absensi
    String status = '';
    Color colorStatus = Colors.black;
    if (widget.absen.hadir == 1) {
      status = 'Hadir';
      colorStatus = CustomTheme.kCrayolaGreen;
    }
    if (widget.absen.terlambat == 1) {
      status = 'Terlambat';
      colorStatus = CustomTheme.kDarkRed;
    }
    if (widget.absen.izin == 1) {
      status = 'Izin';
      colorStatus = Colors.amber;
    }
    if (widget.absen.sakit == 1) {
      status = 'Sakit';
      colorStatus = Colors.amber;
    }
    if (widget.absen.cuti == 1) {
      status = 'Cuti';
      colorStatus = Colors.amber;
    }
    if (widget.absen.dayoff == 1) {
      status = 'Hari Off';
      colorStatus = CustomTheme.kCrayolaGreen;
    }
    if (widget.absen.tanpaKeterangan == 1) {
      status = 'Tanpa Keterangan';
      colorStatus = CustomTheme.kDarkRed;
    }
    String keterangan = widget.absen.keterangan ?? "-";

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20).r,
      child: GestureDetector(
        onTap: (() {
          setState(() {
            isOpen = !isOpen;
          });
        }),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.4,
                      maxChildSize: 1,
                      builder: (_, controller) => Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(0))),
                        padding: const EdgeInsets.all(16).w,
                        child: ListView(
                          controller: controller,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 32,
                                bottom: 31,
                                left: 21,
                                right: 20,
                              ).r,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 200),
                                        child: Text(
                                          widget.currUser.namaKaryawan!,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true,
                                        ),
                                      ),
                                      Icon(
                                        Icons.close,
                                        size: 24.w,
                                        color: const Color(0xFF1F1F1F),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20.sp,
                                          ),
                                          Text(
                                            "Hari/tanggal",
                                            style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6.h,
                                          ),
                                          Text(
                                            DateFormat('EEEE dd MMMM yyyy',
                                                    'id_ID')
                                                .format(DateTime.parse(
                                                    widget.absen.tglAbsen!)),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 30.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20.sp,
                                          ),
                                          Text(
                                            "Status",
                                            style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6.h,
                                          ),
                                          Text(
                                            status,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20.sp,
                                          ),
                                          Text(
                                            "Absen Masuk",
                                            style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6.h,
                                          ),
                                          widget.absen.checkIn != null
                                              ? Text(
                                                  DateFormat('HH:mm').format(
                                                      DateTime.parse(widget
                                                          .absen.checkIn!)),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )
                                              : const Text("--:--"),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20.sp,
                                          ),
                                          Text(
                                            "Absen Keluar",
                                            style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6.h,
                                          ),
                                          widget.absen.checkOut != null
                                              ? Text(
                                                  DateFormat('HH:mm').format(
                                                      DateTime.parse(widget
                                                          .absen.checkOut!)),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )
                                              : const Text("--:--"),
                                        ],
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Text(
                                        "Keterangan",
                                        style: TextStyle(
                                          color: const Color(0xFF585858),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        keterangan,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                        top: 20, bottom: 18, right: 6, left: 20)
                    .r,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7B0),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        padding: const EdgeInsets.only(
                                top: 20, bottom: 20, left: 17, right: 17)
                            .r,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd').format(
                                  DateTime.parse(widget.absen.tglAbsen!)),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              DateFormat.EEEE('id_ID').format(
                                  DateTime.parse(widget.absen.tglAbsen!)),
                              style: TextStyle(
                                color: const Color(0xFF585858),
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 0, child: SizedBox(width: 18.w)),
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, left: 20).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    widget.absen.checkIn != null
                                        ? Text(
                                            DateFormat('HH:mm').format(
                                                DateTime.parse(
                                                    widget.absen.checkIn!)),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600),
                                          )
                                        : const Text("--:--"),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text(
                                      "Absen Masuk",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF585858)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Container(
                                  color: const Color(0xFFE2E2E2),
                                  height: 42.h,
                                  width: 1.w,
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Column(
                                  children: [
                                    widget.absen.checkOut != null
                                        ? Text(
                                            DateFormat('HH:mm').format(
                                                DateTime.parse(
                                                    widget.absen.checkOut!)),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600),
                                          )
                                        : const Text("--:--"),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text(
                                      "Absen Keluar",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF585858)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            RPadding(
                              padding: const EdgeInsets.only(left: 85).r,
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFFE2E2E2),
              width: 350.w,
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }
}
