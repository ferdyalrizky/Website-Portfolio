import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:intl/intl.dart';

import '../../../../../../../models/lembur.dart';
import '../../../../../../../utils/public_func.dart';

class ListItemSummaryRutinitasAktifitas extends StatefulWidget {
  final Lembur lembur;
  const ListItemSummaryRutinitasAktifitas({super.key, required this.lembur});

  @override
  State<ListItemSummaryRutinitasAktifitas> createState() =>
      _ListItemSummaryRutinitasAktifitasState();
}

bool isOpen = false;

class _ListItemSummaryRutinitasAktifitasState
    extends State<ListItemSummaryRutinitasAktifitas> {
  String status = '';
  int statusNum = 0;
  late IconData icon;

  _onSetStatus() {
    status = '';
    statusNum = 0;

    setState(() {
      if (widget.lembur.status == 0 &&
          widget.lembur.disetujui == 0 &&
          widget.lembur.diverifikasi == 0) {
        status = 'Belum Dikirim';
        statusNum = 1;
      } else if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 0 &&
          widget.lembur.diverifikasi == 0) {
        status = "Menunggu Disetujui Manager";
        statusNum = 2;
      } else if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 1 &&
          widget.lembur.diverifikasi == 0) {
        status = "Menunggu Verif HRD";
        statusNum = 3;
      } else if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 1 &&
          widget.lembur.diverifikasi == 1) {
        status = 'Approved';
        statusNum = 4;
      }
    });
  }

  @override
  void initState() {
    _onSetStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 2, right: 2),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isOpen = !isOpen;
              });
            },
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => makeDismissible(
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 1,
                      builder: (_, controller) => Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(0))),
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          controller: controller,
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                        bottom: 6,
                                        left: 8,
                                        right: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: statusNum == 5
                                            ? Colors.red
                                            : statusNum == 2
                                                ? const Color(0xFFE69E00)
                                                : Colors.green,
                                      ),
                                      child: Text(
                                        statusNum == 1
                                            ? "Ditolak"
                                            : statusNum == 2
                                                ? "Menunggu persetujuan finance"
                                                : "Disetujui",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: const Icon(
                                        Icons.close,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Nama Karyawan",
                                      style: TextStyle(
                                          color: Color(0xFF585858),
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.lembur.namaKaryawan!,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Tanggal kwitansi",
                                          style: TextStyle(
                                              color: Color(0xFF585858),
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.lembur.tglLembur!)),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Jumlah uang",
                                          style: TextStyle(
                                              color: Color(0xFF585858),
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          'Rp 2.000.000',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "Deskripsi",
                                  style: TextStyle(
                                      color: Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "${widget.lembur.keperluanLembur}",
                                  style: const TextStyle(
                                      color: Color(0xFF585858),
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                const Text(
                                  "Bukti Klaim biaya",
                                  style: TextStyle(
                                      color: Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.file_copy_outlined,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      "File unggahan bukti klaim biaya",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF585858),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Lihat",
                                        style: TextStyle(
                                          color: Color(0xFF142638),
                                          decoration: TextDecoration.underline,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  "Riwayat pengajuan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF585858),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (statusNum >= 2) ...[
                                  KTimeLineStep(
                                    text: "Pengajuan lembur dibuat",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    color: Colors.black,
                                    warna: Colors.grey,
                                    isFirst: true,
                                    isLast: false,
                                    isMiddle: false,
                                    idx: 0,
                                  ),
                                ],
                                if (statusNum >= 2) ...[
                                  KTimeLineStep(
                                    text:
                                        "Pengajuan lembur telah dikirimkan untuk menunggu disetujui",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    isFirst: false,
                                    isLast: statusNum == 3 ? false : true,
                                    isMiddle: false,
                                    color: statusNum == 2
                                        ? const Color(0xFFE69E00)
                                        : Colors.black,
                                    warna: statusNum == 2
                                        ? const Color(0xFFE69E00)
                                        : Colors.grey,
                                    idx: 1,
                                  ),
                                ],
                                if (statusNum == 3) ...[
                                  KTimeLineStep(
                                    text:
                                        "Pengajuan lembur telah disetujui oleh leader/SPV",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    isFirst: false,
                                    isLast: false,
                                    isMiddle: true,
                                    color: Colors.black,
                                    warna: Colors.grey,
                                    idx: 2,
                                  ),
                                ],
                                if (statusNum == 3) ...[
                                  KTimeLineStep(
                                    text:
                                        "Pengajuan lembur telah disetujui manager",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    isFirst: false,
                                    isLast: false,
                                    isMiddle: true,
                                    color: Colors.black,
                                    warna: Colors.grey,
                                    idx: 2,
                                  ),
                                ],
                                if (statusNum == 3) ...[
                                  KTimeLineStep(
                                    text: "Pengajuan lembur telah disetujui",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    isFirst: false,
                                    isLast: true,
                                    isMiddle: false,
                                    color: Colors.green,
                                    warna: Colors.green,
                                    idx: 2,
                                  ),
                                ],
                                if (statusNum == 1) ...[
                                  KTimeLineStep(
                                    text: "Pengajuan lembur telah Ditolak",
                                    date:
                                        DateFormat('MMM d\n').format(DateTime.parse(widget.lembur.tglLembur!)),
                                    time:
                                        timeFormat(widget.lembur.jamMulaiLembur!),
                                    isFirst: false,
                                    isLast: true,
                                    isMiddle: false,
                                    color: Colors.red,
                                    warna: Colors.red,
                                    idx: 2,
                                  ),
                                ],
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
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color(0xFFC9C9C9),
                    width: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.only(
                      top: 3, bottom: 9, right: 6, left: 1),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 0,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      DateFormat('E').format(DateTime.now()),
                                      style: const TextStyle(
                                          color: Color(0xFF717171),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      DateFormat('MM').format(DateTime.now()),
                                      style: const TextStyle(
                                          color: Color(0xFF121212),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                Container(
                                    height: 31,
                                    width: 2,
                                    color: const Color(0xFFBCBCBC)),
                              ],
                            ),
                          ),
                          const Expanded(flex: 0, child: SizedBox(width: 18)),
                          Expanded(
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                    left: 8,
                                    right: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: statusNum == 1
                                        ? Colors.red
                                        : statusNum == 2
                                            ? const Color(0xFFFFF3D9)
                                            : const Color(0xFFE8F4E3),
                                  ),
                                  child: Text(
                                    statusNum == 1
                                        ? "Ditolak"
                                        : statusNum == 2
                                            ? "Sedang"
                                            : "Disetujui",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: statusNum == 1
                                          ? const Color(
                                              0xFFB31312) // change color for statusNum 1
                                          : statusNum == 2
                                              ? const Color(
                                                  0xFFFFB000) // change color for statusNum 2
                                              : const Color(
                                                  0xFF65B741), // default color
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.lembur.namaKaryawan!,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Tanggal kwitansi",
                                          style: TextStyle(
                                              color: Color(0xFF717171),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.lembur.tglLembur!)),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Jumlah uang",
                                          style: TextStyle(
                                              color: Color(0xFF717171),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'Rp 2.000.000',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
