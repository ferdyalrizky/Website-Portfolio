// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_area_text_cuti.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomTextAreaCuti extends StatelessWidget {
  final String header;
  final String textAreaName;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final bool isEnabled;
  const CustomTextAreaCuti({
    super.key,
    required this.header,
    required this.textAreaName,
    this.hintText = "",
    this.labelText = "",
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 0, bottom: 10),
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomAreaTextCuti(
            isRequired: isRequired,
            isEnable: isEnabled,
            hintText: hintText,
            labelText: labelText,
            name: textAreaName,
          ),
        ],
      ),
    );
  }
}
