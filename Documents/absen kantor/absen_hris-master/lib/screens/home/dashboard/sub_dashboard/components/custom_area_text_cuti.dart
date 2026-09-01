import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomAreaTextCuti extends StatelessWidget {
  final String name;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final bool isEnable;
  const CustomAreaTextCuti({
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
            labelText: labelText,
            labelStyle: const TextStyle(
                color: Color(0xFF626262),
                fontWeight: FontWeight.w400,
                fontSize: 14),
            hintStyle: const TextStyle(color: Colors.black),
            filled: !isEnable,
            fillColor: isEnable ? Colors.white : Colors.grey,
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
          maxLines: 1,
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
