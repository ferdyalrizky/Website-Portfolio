// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

import '../../../../../../../../theme/colors/custom_theme.dart';

class ListSikCutiSendiriHeader extends StatelessWidget {
  final int sisaCutiTahunan;
  final int totalSikCuti;
  final int totalCutiNormatif;
  final int totalCutiTahunan;
  final int totalBelumDikirim;
  final int totalMenungguVerif;
  final int totalApprove;
  const ListSikCutiSendiriHeader({
    super.key,
    required this.totalSikCuti,
    required this.totalCutiNormatif,
    required this.totalCutiTahunan,
    required this.totalBelumDikirim,
    required this.totalMenungguVerif,
    required this.totalApprove,
    required this.sisaCutiTahunan,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                columnHeader(sisaCutiTahunan, 'Sisa\nCuti'),
                columnHeader(totalSikCuti, 'Total\nCuti'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                columnHeader(totalBelumDikirim, 'Belum\nDikirim'),
                columnHeader(totalMenungguVerif, 'Menunggu\nDisetujui'),
                columnHeader(totalApprove, 'Disetujui\n'),
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
