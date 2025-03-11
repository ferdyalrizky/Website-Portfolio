import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/izin.dart';
import '../../../../../models/karyawan.dart';

import 'dart:math' as math;

bool isOpen = false;

class ListItemIzinAnakBuah extends StatefulWidget {
  final Izin izin;
  final Karyawan currUser;
  final Karyawan thisUser;
  final Function onCallback;
  const ListItemIzinAnakBuah({
    super.key,
    required this.izin,
    required this.currUser,
    required this.thisUser,
    required this.onCallback,
  });

  @override
  State<ListItemIzinAnakBuah> createState() => _ListItemIzinAnakBuahState();
}

class _ListItemIzinAnakBuahState extends State<ListItemIzinAnakBuah> {
  @override
  Widget build(BuildContext context) {
    String status = "";
    int statusNum = 0;

    if (widget.izin.disetujuhi == 0 && widget.izin.diverifikasi == 0) {
      status = 'Menunggu Approval Anda';
      statusNum = 1;
    } else if (widget.izin.disetujuhi == 1 && widget.izin.diverifikasi == 0) {
      status = 'Menunggu Verifikasi HRD';
      statusNum = 2;
    } else if (widget.izin.disetujuhi == 1 && widget.izin.diverifikasi == 1) {
      status = 'Disetujui';
      statusNum = 3;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isOpen = !isOpen;
          });
        },
        child: Card(
          shadowColor: Colors.grey,
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    backgroundColor: statusNum == 1
                        ? Colors.red
                        : statusNum == 2
                            ? Colors.amber
                            : Colors.green,
                    child: Icon(
                      statusNum == 1
                          ? Icons.telegram_outlined
                          : statusNum == 2
                              ? Icons.access_time_sharp
                              : Icons.check,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 1,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(widget.thisUser.namaKaryawan!),
                      Text('Keperluan : ${widget.izin.keperluan}'),
                      widget.izin.keperluan == "Datang Telat"
                          ? Text('Jam : ${widget.izin.dtgTelat}')
                          : widget.izin.keperluan == "Pulang Cepat"
                              ? Text('Jam : ${widget.izin.pulangCpt}')
                              : Text(
                                  'Jam : ${widget.izin.jamMasuk} - ${widget.izin.jamKeluar}'),
                      Text(
                        "Tgl Izin : ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.izin.tglIzin!))}",
                      ),
                      Text('Status : $status'),
                      isOpen
                          ? Text('Keterangan : ${widget.izin.keterangan}')
                          : Container(),
                      isOpen
                          ? statusNum == 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.send,
                                        size: 15,
                                      ),
                                      label: const Text("Approve"),
                                      onPressed: () {
                                        //TODO : _onApproveBtnPress
                                      },
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 15,
                                      ),
                                      label: const Text('Tolak'),
                                      onPressed: () {
                                        //TODO : _onTolakBtnPress
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent),
                                    ),
                                  ],
                                )
                              : Container()
                          : Container(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Transform.rotate(
                    angle: isOpen ? 180 * math.pi / 180 : 180 * math.pi,
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
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
