import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/theme/colors/text_style.dart';
import 'package:hris_v2/widgets/custom_form_builder_text_field.dart';

class CustomTextFieldAndHeader extends StatelessWidget {
  final String header;
  final String txtFieldName;
  final TextInputType keyboardType;
  final String hintText;
  final String labelText;
  final bool isEnabled;
  final bool isRequired;
  final bool isObscure;
  const CustomTextFieldAndHeader({
    super.key,
    required this.header,
    required this.txtFieldName,
    required this.keyboardType,
    this.hintText = "",
    this.labelText = "",
    this.isEnabled = true,
    this.isRequired = false,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 2, bottom: 20).r,
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
                    color: const Color(0xFF000000),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          CustomFormBuilderTextField(
            fieldName: txtFieldName,
            keyboardType: keyboardType,
            hintText: hintText,
            labelText: labelText,
            isEnabled: isEnabled,
            isRequired: isRequired,
            obscureText: isObscure,
          ),
        ],
      ),
    );
  }
}
