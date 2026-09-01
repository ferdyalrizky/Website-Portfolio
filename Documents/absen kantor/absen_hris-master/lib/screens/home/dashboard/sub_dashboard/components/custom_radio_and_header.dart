import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomRadioAndHeader extends StatelessWidget {
  final String header;
  final String radioName;
  final String hintText;
  final String labelText;
  final bool isEnabled;
  final bool isRequired;
  final List<FormBuilderFieldOption> options;
  const CustomRadioAndHeader({
    super.key,
    required this.header,
    required this.radioName,
    this.hintText = "",
    this.labelText = "",
    this.isEnabled = true,
    this.isRequired = false,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: CustomTextStyle.bodySmall,
              children: [
                TextSpan(text: header),
                isRequired ? CustomTextStyle.textWarningRequired() : const TextSpan()
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderRadioGroup(
            name: radioName,
            options: options,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0, color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
