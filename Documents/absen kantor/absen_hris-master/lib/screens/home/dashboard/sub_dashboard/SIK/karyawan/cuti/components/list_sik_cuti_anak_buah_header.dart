// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

import '../../../../../../../../theme/colors/custom_theme.dart';

class ListSikCutiAnakBuahHeader extends StatelessWidget {
  final int totalSikCutiAnakBuah;
  final int totalMenungguApprove;
  final int totalMenungguVerif;
  final int totalApprove;
  const ListSikCutiAnakBuahHeader({
    super.key,
    required this.totalSikCutiAnakBuah,
    required this.totalMenungguApprove,
    required this.totalMenungguVerif,
    required this.totalApprove,
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
            child: columnHeader(totalSikCutiAnakBuah, 'Total Cuti'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                columnHeader(totalMenungguApprove, 'Belum\nApprove'),
                columnHeader(totalMenungguVerif, 'Belum\nVerif HRD'),
                columnHeader(totalApprove, 'Approved\n'),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
