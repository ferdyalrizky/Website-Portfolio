// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomTextAreaAndHeader extends StatelessWidget {
  final String header;
  final String textAreaName;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final bool isEnabled;
  const CustomTextAreaAndHeader({
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
      margin: const EdgeInsets.only(left: 2.0, right: 0, bottom: 20).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: CustomTextStyle.bodySmall,
              children: [
                TextSpan(
                  text: header,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          CustomTextArea(
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
