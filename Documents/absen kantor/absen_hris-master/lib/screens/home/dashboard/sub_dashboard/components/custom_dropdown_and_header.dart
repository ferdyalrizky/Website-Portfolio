import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomDropdownAndHeader extends StatelessWidget {
  final String header;
  final String dropdownName;
  final List<String> items;
  final String labelText;
  final String hintText;
  final bool isRequired;
  final Function(String?)? onChanged;
  const CustomDropdownAndHeader({
    super.key,
    required this.header,
    required this.dropdownName,
    required this.items,
    this.labelText = "",
    this.hintText = "",
    this.isRequired = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                isRequired
                    ? CustomTextStyle.textWarningRequired()
                    : const TextSpan()
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderDropdown(
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.blue[500]),
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.blue[900]),
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
            name: dropdownName,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
