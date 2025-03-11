import 'package:flutter/material.dart';
import 'package:hris_v2/models/penilaian_7.dart';

class HasilPenilaian extends StatefulWidget {
  final PenilaianResult result;

  const HasilPenilaian({super.key, required this.result});

  @override
  State<HasilPenilaian> createState() => _HasilPenilaianState();
}

class _HasilPenilaianState extends State<HasilPenilaian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Penilaian'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Score: ${widget.result.score}'),
            Text('Nilai: ${widget.result.nilai}'),
            Text('Hadir: ${widget.result.hadir}'),
            Text('Skil: ${widget.result.skil}'),
            Text('Kerjabro: ${widget.result.kerjabro}'),
            Text('Tampilann: ${widget.result.tampilann}'),
            Text('Keterangan: ${widget.result.keterangan}'),
          ],
        ),
      ),
    );
  }
}
