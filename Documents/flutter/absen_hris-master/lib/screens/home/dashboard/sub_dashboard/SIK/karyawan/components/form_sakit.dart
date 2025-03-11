import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime_range_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_image_picker_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

import '../../../components/custom_text_area_and_header.dart';

class FormSikSakit extends StatelessWidget {
  const FormSikSakit({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFieldAndHeader(
          header: "Nama Pembuat",
          txtFieldName: "pembuat",
          keyboardType: TextInputType.name,
          isEnabled: false,
        ),
        CustomDateTimeRangeAndHeader(
          header: "Tanggal Mulai - Selesai Sakit",
          dateTimeName: "range-sakit",
          labelText: "Klik untuk memilih tanggal sakit",
          isRequired: true,
        ),
        CustomTextAreaAndHeader(
          header: "Keterangan",
          textAreaName: "keterangan-sakit",
          labelText: "Tulis Keterangan Sakit Anda",
          isRequired: true,
        ),
        CustomImagePickerAndHeader(
          header: "Upload Surat Dokter",
          imagePickerName: 'foto-surat-dokter',
          isRequired: true,
        ),
      ],
    );
  }
}
