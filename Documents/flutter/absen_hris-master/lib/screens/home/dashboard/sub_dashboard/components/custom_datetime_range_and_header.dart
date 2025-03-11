// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomDateTimeRangeAndHeader extends StatelessWidget {
  final String header;
  final String dateTimeName;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final Function(DateTimeRange?)? onChanged;

  const CustomDateTimeRangeAndHeader({
    super.key,
    required this.header,
    required this.dateTimeName,
    this.hintText = "",
    this.labelText = "",
    this.isRequired = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    int thisYear = DateTime.now().year;

    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 0, bottom: 20),
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
                      color: Color(0xFF000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderDateRangePicker(
            validator: (value) {
              if (isRequired) {
                if (value == null) {
                  return 'Harus Diisi';
                }
              }
              return null;
            },
            firstDate: DateTime(thisYear),
            lastDate: DateTime(thisYear + 2),
            format: DateFormat('dd/MM/yyyy'),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[800]),
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
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
