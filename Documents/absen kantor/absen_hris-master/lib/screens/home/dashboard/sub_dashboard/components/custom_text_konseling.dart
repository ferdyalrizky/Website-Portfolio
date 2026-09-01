import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextKonseling extends StatelessWidget {
  final String name;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final bool isEnable;
  final TextEditingController controller; // Make this non-nullable

  const CustomTextKonseling({
    Key? key,
    required this.name,
    this.hintText = "",
    this.labelText = "",
    required this.isRequired,
    required this.isEnable,
    required this.controller, // Make this required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          controller: controller, // Use the controller
          enabled: isEnable,
          name: name,
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
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '*Harap Isi Keterangan';
            }
            return null;
          },
        ),
      ],
    );
  }
}
