import 'package:flutter/material.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';

class ListIzinSendiriHeader extends StatelessWidget {
  final int totalIzin;
  final int totalBelumDikirim;
  final int totalMenungguVerif;
  final int totalApprove;
  const ListIzinSendiriHeader(
      {super.key,
      required this.totalIzin,
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
              child: columnHeader(totalIzin, "Total\nIzin")),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                columnHeader(totalBelumDikirim, 'Belum\nDikirim'),
                columnHeader(totalMenungguVerif, 'Menunggu\nDisetujui'),
                columnHeader(totalApprove, 'Disetujui\n'),
              ],
            ),
          )
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
