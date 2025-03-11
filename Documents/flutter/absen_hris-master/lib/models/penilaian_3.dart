class Absensi {
  final String absen;
  final List<String> options;
  final int pilihanPertama;
  final int pilihanKedua;

  const Absensi({
    required this.pilihanPertama,
    required this.pilihanKedua,
    required this.absen,
    required this.options,
  });
}
