class Question {
  final String question;
  final List<String> options;
  final int pilihanPertama;
  final int pilihanKedua;
  final int pilihanKetiga;
  final int pilihanKeempat;

  const Question({
    required this.pilihanPertama,
    required this.pilihanKedua,
    required this.pilihanKetiga,
    required this.pilihanKeempat,
    required this.question,
    required this.options,
  });
}
