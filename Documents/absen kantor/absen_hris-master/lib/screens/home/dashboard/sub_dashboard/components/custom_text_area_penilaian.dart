import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextAreaPenilaian extends StatelessWidget {
  final String name;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final bool isEnable;
  const CustomTextAreaPenilaian({
    super.key,
    required this.name,
    this.hintText = "",
    this.labelText = "",
    required this.isRequired,
    required this.isEnable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          enabled: isEnable,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            hintText: hintText,
            hintStyle: TextStyle(
                color: const Color(0xFF626262),
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
            labelStyle: TextStyle(
                color: const Color(0xFF626262),
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFF1A1A1A),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFF1A1A1A),
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFF1A1A1A),
                width: 1.0,
              ),
            ),
          ),
          name: name,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          minLines: 3,
          maxLines: 6,
          validator: (value) {
            if (isRequired) {
              if (value == null) {
                return '*Harap Isi Keterangan';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
