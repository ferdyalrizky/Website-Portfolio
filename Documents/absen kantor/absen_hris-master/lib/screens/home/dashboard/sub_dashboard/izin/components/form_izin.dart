import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime_picker_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

class FormIzin extends StatefulWidget {
  const FormIzin({
    super.key,
  });

  @override
  State<FormIzin> createState() => _FormIzinState();
}

class _FormIzinState extends State<FormIzin> {
  List<String> listKeperluanIzin = [
    "Datang Telat",
    "Pulang Cepat",
    "Izin Sementara"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTextFieldAndHeader(
          header: "Nama Pembuat",
          txtFieldName: "pembuat",
          keyboardType: TextInputType.name,
          isEnabled: false,
        ),
        CustomDropdownAndHeader(
          header: "Keperluan Izin",
          dropdownName: "keperluan",
          items: listKeperluanIzin,
        ),
        const CustomDateTimePickerAndHeader(
          header: "Tanggal & Jam Izin",
          dateTimeName: "tanggal-jam-izin",
          labelText: "Klik untuk memilih tanggal dan jam izin",
        ),
        const CustomTextAreaAndHeader(
          header: "Keterangan",
          textAreaName: "keterangan-luar-shift",
          labelText: "Tulis Keterangan/Alasan anda izin",
        ),
      ],
    );
  }
}
