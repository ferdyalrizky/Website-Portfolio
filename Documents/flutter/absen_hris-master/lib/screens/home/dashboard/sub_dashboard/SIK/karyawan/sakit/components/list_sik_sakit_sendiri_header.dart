import 'package:flutter/material.dart';
import '../../../../../../../../theme/colors/custom_theme.dart';

class ListSikSakitSendiriHeader extends StatelessWidget {
  final int totalSikSakit;
  final int totalBelumDikirim;
  final int totalMenungguVerif;
  final int totalApprove;
  const ListSikSakitSendiriHeader(
      {super.key,
      required this.totalSikSakit,
      required this.totalBelumDikirim,
      required this.totalMenungguVerif,
      required this.totalApprove});

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
            child: columnHeader(totalSikSakit, 'Total Sakit'),
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
