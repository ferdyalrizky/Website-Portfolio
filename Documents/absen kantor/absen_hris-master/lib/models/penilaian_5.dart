class IntegritasKerja {
  final String kerja;
  final List<String> options;
  final int pilihanPertama;
  final int pilihanKedua;
  final int pilihanKetiga;
  final int pilihanKeempat;

  const IntegritasKerja({
    required this.pilihanPertama,
    required this.pilihanKedua,
    required this.pilihanKetiga,
    required this.pilihanKeempat,
    required this.kerja,
    required this.options,
  });
}
