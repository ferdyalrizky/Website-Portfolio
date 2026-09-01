// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';

class ListSpkHeader extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final int totalSpkLembur;
  final int totalBelumKirim;
  final int totalBelumVerifHrd;
  final int totalApprove;
  const ListSpkHeader({
    super.key,
    required this.totalBelumKirim,
    required this.totalBelumVerifHrd,
    required this.totalSpkLembur,
    required this.totalApprove,
    required this.text1,
    required this.text2,
    required this.text3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CustomTheme.kFagettiBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: columnHeader(totalSpkLembur, "Total SPK"),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                columnHeader(totalBelumKirim, text1),
                columnHeader(totalBelumVerifHrd, text2),
                columnHeader(totalApprove, text3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column columnHeader(int value, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
