import 'package:flutter/material.dart';
import '../../../../../../../../theme/colors/custom_theme.dart';

class ListSikSakitAnakBuah extends StatelessWidget {
  final int totalSikSakitKaryawan;
  final int totalMenungguApprove;
  final int totalMenungguVerif;
  final int totalApprove;
  const ListSikSakitAnakBuah(
      {super.key,
      required this.totalSikSakitKaryawan,
      required this.totalMenungguApprove,
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
            child: columnHeader(totalSikSakitKaryawan, 'Total Sakit'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
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
