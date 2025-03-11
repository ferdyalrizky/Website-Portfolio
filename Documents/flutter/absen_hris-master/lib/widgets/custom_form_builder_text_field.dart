import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFormBuilderTextField extends StatefulWidget {
  final String fieldName;
  final bool obscureText;
  final TextInputType keyboardType;
  final String hintText;
  final String labelText;
  final bool isEnabled;
  final bool isRequired;

  const CustomFormBuilderTextField({
    super.key,
    required this.fieldName,
    this.obscureText = false,
    required this.keyboardType,
    required this.hintText,
    required this.labelText,
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  State<CustomFormBuilderTextField> createState() =>
      _CustomFormBuilderTextFieldState();
}

class _CustomFormBuilderTextFieldState
    extends State<CustomFormBuilderTextField> {
  bool passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.fieldName,
      style: TextStyle(
        color: const Color(0xFF121212),
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      keyboardType: widget.keyboardType,
      validator: (value) {
        if (widget.isRequired) {
          if (value == null || value.isEmpty) {
            return 'Harus Diisi';
          }
        }
        return null;
      },
      obscureText: widget.obscureText ? passwordVisible : false,
      enabled: widget.isEnabled,
      decoration: InputDecoration(
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  print('called');
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              )
            : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.blue[500]),
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.blue[900]),
        filled: !widget.isEnabled,
        fillColor: widget.isEnabled ? Colors.white : const Color(0xFFDBDBDB),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Color(0xFF626262),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: const Color(0xFF626262),
            width: 1.w,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: const Color(0xFF626262),
            width: 1.w,
          ),
        ),
      ),
    );
  }
}
