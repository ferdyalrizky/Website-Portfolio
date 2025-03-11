// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomDateTimePickerAndHeader extends StatelessWidget {
  final String header;
  final String dateTimeName;
  final String hintText;
  final String labelText;
  final bool isRequired;

  const CustomDateTimePickerAndHeader({
    super.key,
    required this.header,
    required this.dateTimeName,
    this.hintText = "",
    this.labelText = "",
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: CustomTextStyle.bodySmall,
              children: [
                TextSpan(
                    text: header,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderDateTimePicker(
            validator: (value) {
              if (isRequired) {
                if (value == null) {
                  return '*Harap Isi Tanggal & Jam';
                }
              }
              return null;
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF000000)),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[800]),
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.grey[800]),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.blue,
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
            name: dateTimeName,
          ),
        ],
      ),
    );
  }
}
