import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/colors/text_style.dart';

class CustomDropdownField extends StatelessWidget {
  final String header;
  final String dropdownName;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const CustomDropdownField({
    Key? key,
    required this.header,
    required this.dropdownName,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                if (isRequired)
                  TextSpan(
                    text: '',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black), // Border color
              borderRadius: BorderRadius.circular(4.0), // Rounded corners
            ),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none, // Remove default border
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10.h, horizontal: 12.w), // Padding
              ),
              hint: Text("Pilih $header"), // Placeholder text
              value: selectedValue, // Current selected value
              isExpanded: true, // Make the dropdown take the full width
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
