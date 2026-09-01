import 'package:hris_v2/models/meeting.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:intl/intl.dart';

Pertemuan convertMeetingToPertemuan(Meeting meeting) {
  return Pertemuan(
    id: meeting.id,
    idKaryawan: meeting.idKaryawan,
    nip: meeting.nip,
    judul: meeting.judul,
    jenisRutinitas: meeting.jenisRutinitas,
    typePertemuan: meeting.typePertemuan,
    tglSelesai: meeting.tglSelesai?.toIso8601String(),
    tglPertemuan: DateFormat('dd MMMM yyyy').format(meeting.tglPertemuan),
    tenggatWaktu: meeting.tenggatWaktu?.toIso8601String(),
    peserta: meeting.peserta
        .map((p) => Babu(
              nip: p.nip,
              name: p.name,
              attendance: p.attendance,
            ))
        .toList(),
    jamAwal: meeting.jamAwal,
    jamAkhir: meeting.jamAkhir,
    durasi: meeting.durasi,
    pengingat: meeting.pengingat,
    lokasi: meeting.lokasi,
    detailLokasi: meeting.detailLokasi,
    deskripsi: meeting.deskripsi,
    tingkatan: meeting.tingkatan,
    linkPertemuan: meeting.linkPertemuan,
    idDepartemen: meeting.idDepartemen?.toString(),
    bisnisId: meeting.bisnisId?.toString(),
    areaKerjaId: meeting.areaKerjaId?.toString(),
    kehadiran: meeting.kehadiran,
    createdBy: meeting.createdBy,
    isCanDelete: false, // Set this based on your logic
    isCanEdit: false, // Set this based on your logic
    isAttendance: false, // Set this based on your logic
    creator: meeting.createdBy, // Adjust as necessary
  );
}
