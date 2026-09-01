// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

import '../../../../../theme/colors/text_style.dart';

class CustomImagePickerAndHeader extends StatelessWidget {
  final String header;
  final String hintText;
  final String labelText;
  final bool isRequired;
  final String imagePickerName;
  const CustomImagePickerAndHeader({
    super.key,
    required this.header,
    this.hintText = "",
    this.labelText = "",
    this.isRequired = false,
    required this.imagePickerName,
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
                isRequired
                    ? CustomTextStyle.textWarningRequired()
                    : const TextSpan()
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderImagePicker(
            validator: (value) {
              if (isRequired) {
                if (value == null) {
                  return 'Harus Diisi';
                }
              }
              return null;
            },
            maxImages: 1,
            previewHeight: 200,
            previewWidth: 200,
            name: imagePickerName,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
