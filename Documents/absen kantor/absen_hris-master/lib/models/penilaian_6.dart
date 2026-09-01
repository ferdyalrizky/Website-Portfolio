class Penampilan {
  final String tampilan;
  final List<String> options;
  final int pilihanPertama;
  final int pilihanKedua;
  final int pilihanKetiga;
  final int pilihanKeempat;

  const Penampilan({
    required this.pilihanPertama,
    required this.pilihanKedua,
    required this.pilihanKetiga,
    required this.pilihanKeempat,
    required this.tampilan,
    required this.options,
  });
}
