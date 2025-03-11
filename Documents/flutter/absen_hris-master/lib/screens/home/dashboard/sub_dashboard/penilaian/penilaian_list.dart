import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/models/penilaian_7.dart';
import 'package:hris_v2/models/penilaian_absensi.dart';
import 'package:hris_v2/models/penilaian_insiatif.dart';
import 'package:hris_v2/models/penilaian_integritaskerja.dart';
import 'package:hris_v2/models/penilaian_komunikasi.dart';
import 'package:hris_v2/models/penilaian_penampilan.dart';
import 'package:hris_v2/models/penilaian_teamwork.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_area_pernilaian.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/penilaian/calculation.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/penilaian/hasil_penilaian.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/penilaian/top_penilaian.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'dart:math' as math;

bool isOpen = false;

class Penilaian extends StatefulWidget {
  final Karyawan currUser;
  const Penilaian({super.key, required this.currUser});

  @override
  State<Penilaian> createState() => _PenilaianState();
}

class _PenilaianState extends State<Penilaian> {
  late List<int?> selectedAnswerIndex;
  late List<int?> selectedNilaiIndex;
  late List<int?> selectedAbsensiIndex;
  late List<int?> selectedTeamWorkIndex;
  late List<int?> selectedIntegritasKerjaIndex;
  late List<int?> selectedPenampilanIndex;
  int score = 0;
  int nilai = 0;
  int hadir = 0;
  int skil = 0;
  int kerjabro = 0;
  int tampilann = 0;
  List<bool> isAnswered = List<bool>.filled(questions.length, false);
  List<bool> isInsiatif = List<bool>.filled(insiatif.length, false);
  List<bool> isTeamWork = List<bool>.filled(teamwork.length, false);
  List<bool> isIntegritasKerja =
      List<bool>.filled(integritaskerja.length, false);
  List<bool> isMasuk = List<bool>.filled(masuk.length, false);
  List<bool> isPenampilan = List<bool>.filled(penampilan.length, false);
  @override
  void initState() {
    super.initState();
    selectedAnswerIndex = List<int?>.filled(questions.length, null);
    selectedNilaiIndex = List<int?>.filled(insiatif.length, null);
    selectedAbsensiIndex = List<int?>.filled(masuk.length, null);
    selectedTeamWorkIndex = List<int?>.filled(teamwork.length, null);
    selectedIntegritasKerjaIndex =
        List<int?>.filled(integritaskerja.length, null);
    selectedPenampilanIndex = List<int?>.filled(penampilan.length, null);
  }

  void pickAnswer(int questionIndex, int value) {
    setState(() {
      final question = questions[questionIndex];

      // Remove previous score
      if (selectedAnswerIndex[questionIndex] == question.pilihanPertama) {
        score -= 1;
      } else if (selectedAnswerIndex[questionIndex] == question.pilihanKedua) {
        score -= 2;
      } else if (selectedAnswerIndex[questionIndex] == question.pilihanKetiga) {
        score -= 3;
      } else if (selectedAnswerIndex[questionIndex] ==
          question.pilihanKeempat) {
        score -= 4;
      }

      // Update selected answer index
      selectedAnswerIndex[questionIndex] = value;

      // Add new score
      if (value == question.pilihanPertama) {
        score += 1;
      } else if (value == question.pilihanKedua) {
        score += 2;
      } else if (value == question.pilihanKetiga) {
        score += 3;
      } else if (value == question.pilihanKeempat) {
        score += 4;
      }
    });
  }

  void pickAnswerInsiatif(int nilaiiIndex, int value) {
    setState(() {
      final nilaii = insiatif[nilaiiIndex];

      // Remove previous score
      if (selectedNilaiIndex[nilaiiIndex] == nilaii.pilihanPertama) {
        nilai -= 1;
      } else if (selectedNilaiIndex[nilaiiIndex] == nilaii.pilihanKedua) {
        nilai -= 2;
      } else if (selectedNilaiIndex[nilaiiIndex] == nilaii.pilihanKetiga) {
        nilai -= 3;
      } else if (selectedNilaiIndex[nilaiiIndex] == nilaii.pilihanKeempat) {
        nilai -= 4;
      }

      // Update selected answer index
      selectedNilaiIndex[nilaiiIndex] = value;

      // Add new score
      if (value == nilaii.pilihanPertama) {
        nilai += 1;
      } else if (value == nilaii.pilihanKedua) {
        nilai += 2;
      } else if (value == nilaii.pilihanKetiga) {
        nilai += 3;
      } else if (value == nilaii.pilihanKeempat) {
        nilai += 4;
      }
    });
  }

  void pickAnswerTeamWork(int skillIndex, int value) {
    setState(() {
      final nilaii = insiatif[skillIndex];

      // Remove previous score
      if (selectedTeamWorkIndex[skillIndex] == nilaii.pilihanPertama) {
        skil -= 1;
      } else if (selectedTeamWorkIndex[skillIndex] == nilaii.pilihanKedua) {
        skil -= 2;
      } else if (selectedTeamWorkIndex[skillIndex] == nilaii.pilihanKetiga) {
        skil -= 3;
      } else if (selectedTeamWorkIndex[skillIndex] == nilaii.pilihanKeempat) {
        skil -= 4;
      }

      // Update selected answer index
      selectedTeamWorkIndex[skillIndex] = value;

      // Add new score
      if (value == nilaii.pilihanPertama) {
        skil += 1;
      } else if (value == nilaii.pilihanKedua) {
        skil += 2;
      } else if (value == nilaii.pilihanKetiga) {
        skil += 3;
      } else if (value == nilaii.pilihanKeempat) {
        skil += 4;
      }
    });
  }

  void pickAnswerIntegritasKerja(int kerjaIndex, int value) {
    setState(() {
      final kerja = integritaskerja[kerjaIndex];

      // Remove previous score
      if (selectedIntegritasKerjaIndex[kerjaIndex] == kerja.pilihanPertama) {
        kerjabro -= 1;
      } else if (selectedIntegritasKerjaIndex[kerjaIndex] ==
          kerja.pilihanKedua) {
        kerjabro -= 2;
      } else if (selectedIntegritasKerjaIndex[kerjaIndex] ==
          kerja.pilihanKetiga) {
        kerjabro -= 3;
      } else if (selectedIntegritasKerjaIndex[kerjaIndex] ==
          kerja.pilihanKeempat) {
        kerjabro -= 4;
      }

      // Update selected answer index
      selectedIntegritasKerjaIndex[kerjaIndex] = value;

      // Add new score
      if (value == kerja.pilihanPertama) {
        kerjabro += 1;
      } else if (value == kerja.pilihanKedua) {
        kerjabro += 2;
      } else if (value == kerja.pilihanKetiga) {
        kerjabro += 3;
      } else if (value == kerja.pilihanKeempat) {
        kerjabro += 4;
      }
    });
  }

  void pickAnswerPenampilan(int penampilanIndex, int value) {
    setState(() {
      final tampilan = penampilan[penampilanIndex];

      // Remove previous score
      if (selectedPenampilanIndex[penampilanIndex] == tampilan.pilihanPertama) {
        tampilann -= 1;
      } else if (selectedPenampilanIndex[penampilanIndex] ==
          tampilan.pilihanKedua) {
        tampilann -= 2;
      } else if (selectedPenampilanIndex[penampilanIndex] ==
          tampilan.pilihanKetiga) {
        tampilann -= 3;
      } else if (selectedPenampilanIndex[penampilanIndex] ==
          tampilan.pilihanKeempat) {
        tampilann -= 4;
      }

      // Update selected answer index
      selectedPenampilanIndex[penampilanIndex] = value;

      // Add new score
      if (value == tampilan.pilihanPertama) {
        tampilann += 1;
      } else if (value == tampilan.pilihanKedua) {
        tampilann += 2;
      } else if (value == tampilan.pilihanKetiga) {
        tampilann += 3;
      } else if (value == tampilan.pilihanKeempat) {
        tampilann += 4;
      }
    });
  }

  void pickAbsensi(int absenIndex, int value) {
    setState(() {
      final absen = masuk[absenIndex];

      // Remove previous score
      if (selectedAbsensiIndex[absenIndex] == absen.pilihanPertama) {
        hadir -= 8;
      } else if (selectedAbsensiIndex[absenIndex] == absen.pilihanKedua) {
        hadir -= 12;
      }

      // Update selected answer index
      selectedAbsensiIndex[absenIndex] = value;

      // Add new score
      if (value == absen.pilihanPertama) {
        hadir += 8;
      } else if (value == absen.pilihanKedua) {
        hadir += 12;
      }
    });
  }

  void savePenilaian() {
    PenilaianResult result = PenilaianResult(
      score: score,
      nilai: nilai,
      hadir: hadir,
      skil: skil,
      kerjabro: kerjabro,
      tampilann: tampilann,
      keterangan: "keterangan",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HasilPenilaian(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Performance Review",
          style: TextStyle(fontSize: 24.sp),
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 28.w,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250.h,
          ),
          SvgPicture.asset(
            "assets/images/tidakada.svg",
            width: 350,
            height: 160,
          ),
          Center(
            child: Text(
              "SEGERA HADIR",
              style: GoogleFonts.epilogue(
                  fontSize: 25.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Column(
            children: [
              if (widget.currUser.level == 99) ...[
                Padding(
                  padding: const EdgeInsets.all(12).w,
                  child: TopPenilaian(
                    currUser: widget.currUser,
                    score: score,
                    onScoreChanged: (newScore) {
                      setState(() {
                        score = newScore;
                      });
                    },
                    nilai: nilai,
                    onNilaiChanged: (newNilai) {
                      setState(() {
                        score = newNilai;
                      });
                    },
                    hadir: hadir,
                    onHadirChanged: (newHadir) {
                      setState(() {
                        score = newHadir;
                      });
                    },
                    skil: skil,
                    onSkilChanged: (newSkil) {
                      setState(() {
                        score = newSkil;
                      });
                    },
                    kerjabro: kerjabro,
                    onKerjaBroChanged: (newKerjaBro) {
                      setState(() {
                        score = newKerjaBro;
                      });
                    },
                    tampilann: tampilann,
                    onTampilannChanged: (newTampilanBro) {
                      setState(() {
                        score = newTampilanBro;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, right: 10).r,
                            child: Container(
                              color: const Color.fromARGB(255, 227, 226, 226),
                              height: 2.h,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isOpen = !isOpen;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Review Questions",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "(80%)",
                                        style: TextStyle(fontSize: 15.sp),
                                      )
                                    ],
                                  ),
                                  Transform.rotate(
                                    angle: isOpen
                                        ? 180 * math.pi / 180
                                        : 180 * math.pi,
                                    child: const Icon(
                                      Icons.arrow_drop_down,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isOpen
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8).w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "1. Komunikasi",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        Text(
                                          "Komunikasi",
                                          style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                                  left: 12, right: 12, top: 20)
                                              .r,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 227, 225, 225)),
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: questions.length,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemBuilder:
                                                    (context, questionIndex) {
                                                  final question =
                                                      questions[questionIndex];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        question.question,
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Wrap(
                                                        children: question
                                                            .options
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          int index = entry.key;
                                                          bool isCorrectAnswer =
                                                              true;
                                                          if (index + 1 ==
                                                              question
                                                                  .pilihanPertama) {
                                                            isCorrectAnswer =
                                                                true;
                                                          } else if (index +
                                                                  1 ==
                                                              question
                                                                  .pilihanKedua) {
                                                            isCorrectAnswer =
                                                                true;
                                                          } else if (index +
                                                                  1 ==
                                                              question
                                                                  .pilihanKetiga) {
                                                            isCorrectAnswer =
                                                                true;
                                                          } else if (index +
                                                                  1 ==
                                                              question
                                                                  .pilihanKeempat) {
                                                            isCorrectAnswer =
                                                                true;
                                                          }
                                                          bool isSelected =
                                                              selectedAnswerIndex[
                                                                      questionIndex] ==
                                                                  index;
                                                          bool
                                                              isAlreadyAnswered =
                                                              isAnswered[
                                                                  questionIndex];
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                pickAnswer(
                                                                    questionIndex,
                                                                    index),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5,
                                                                          right:
                                                                              40,
                                                                          left:
                                                                              40)
                                                                      .r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isSelected
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        214,
                                                                        241,
                                                                        252)
                                                                    : Colors
                                                                        .grey
                                                                        .shade100,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0),
                                                                border:
                                                                    Border.all(
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey
                                                                          .shade400,
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Text(
                                                                    entry.value,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                    ],
                                                  );
                                                },
                                              ),
                                              // Score and Progress
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          isOpen
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8).w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "2. Insiatif",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        Text(
                                          "Insiatif",
                                          style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                                  left: 12, right: 12, top: 20)
                                              .r,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 227, 225, 225)),
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: insiatif.length,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemBuilder:
                                                    (context, nilaiiIndex) {
                                                  final nilaii =
                                                      insiatif[nilaiiIndex];
                                                  return Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          nilaii.nilaii,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Wrap(
                                                          children: nilaii
                                                              .options
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index =
                                                                entry.key;
                                                            bool
                                                                isCorrectAnswer =
                                                                true;
                                                            if (index + 1 ==
                                                                nilaii
                                                                    .pilihanPertama) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                nilaii
                                                                    .pilihanKedua) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                nilaii
                                                                    .pilihanKetiga) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                nilaii
                                                                    .pilihanKeempat) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            }
                                                            bool isSelected =
                                                                selectedNilaiIndex[
                                                                        nilaiiIndex] ==
                                                                    index;
                                                            bool
                                                                isAlreadyAnswered =
                                                                isInsiatif[
                                                                    nilaiiIndex];
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  pickAnswerInsiatif(
                                                                      nilaiiIndex,
                                                                      index),
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            40,
                                                                        left:
                                                                            40)
                                                                    .r,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isSelected
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          214,
                                                                          241,
                                                                          252)
                                                                      : Colors
                                                                          .grey
                                                                          .shade100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  border: Border
                                                                      .all(
                                                                    color: isSelected
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    Text(
                                                                      entry
                                                                          .value,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12.sp),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Score and Progress
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          isOpen
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8).w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "3. TeamWork",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        Text(
                                          "TeamWork",
                                          style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                                  left: 12, right: 12, top: 20)
                                              .r,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 227, 225, 225)),
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: teamwork.length,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemBuilder:
                                                    (context, skillIndex) {
                                                  final skill =
                                                      teamwork[skillIndex];
                                                  return Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          skill.skill,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Wrap(
                                                          children: skill
                                                              .options
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index =
                                                                entry.key;
                                                            bool
                                                                isCorrectAnswer =
                                                                true;
                                                            if (index + 1 ==
                                                                skill
                                                                    .pilihanPertama) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                skill
                                                                    .pilihanKedua) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                skill
                                                                    .pilihanKetiga) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                skill
                                                                    .pilihanKeempat) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            }
                                                            bool isSelected =
                                                                selectedTeamWorkIndex[
                                                                        skillIndex] ==
                                                                    index;
                                                            bool
                                                                isAlreadyAnswered =
                                                                isTeamWork[
                                                                    skillIndex];
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  pickAnswerTeamWork(
                                                                      skillIndex,
                                                                      index),
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            40,
                                                                        left:
                                                                            40)
                                                                    .r,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isSelected
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          214,
                                                                          241,
                                                                          252)
                                                                      : Colors
                                                                          .grey
                                                                          .shade100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  border: Border
                                                                      .all(
                                                                    color: isSelected
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    Text(
                                                                      entry
                                                                          .value,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12.sp),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Score and Progress
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          isOpen
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8).w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "4. Integritas Kerja",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        Text(
                                          "Integritas Kerja",
                                          style: TextStyle(
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                                  left: 12, right: 12, top: 20)
                                              .r,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 227, 225, 225)),
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    integritaskerja.length,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemBuilder:
                                                    (context, kerjaIndex) {
                                                  final kerja = integritaskerja[
                                                      kerjaIndex];
                                                  return Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kerja.kerja,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10.h,
                                                        ),
                                                        Wrap(
                                                          children: kerja
                                                              .options
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index =
                                                                entry.key;
                                                            bool
                                                                isCorrectAnswer =
                                                                true;
                                                            if (index + 1 ==
                                                                kerja
                                                                    .pilihanPertama) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                kerja
                                                                    .pilihanKedua) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                kerja
                                                                    .pilihanKetiga) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            } else if (index +
                                                                    1 ==
                                                                kerja
                                                                    .pilihanKeempat) {
                                                              isCorrectAnswer =
                                                                  true;
                                                            }
                                                            bool isSelected =
                                                                selectedIntegritasKerjaIndex[
                                                                        kerjaIndex] ==
                                                                    index;
                                                            bool
                                                                isAlreadyAnswered =
                                                                isIntegritasKerja[
                                                                    kerjaIndex];
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  pickAnswerIntegritasKerja(
                                                                      kerjaIndex,
                                                                      index),
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            40,
                                                                        left:
                                                                            40)
                                                                    .r,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isSelected
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          214,
                                                                          241,
                                                                          252)
                                                                      : Colors
                                                                          .grey
                                                                          .shade100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  border: Border
                                                                      .all(
                                                                    color: isSelected
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    Text(
                                                                      entry
                                                                          .value,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12.sp),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Score and Progress
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, right: 10).r,
                            child: Container(
                              color: const Color.fromARGB(255, 227, 226, 226),
                              height: 2.h,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              padding: const EdgeInsets.all(8).w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "ABSENSI",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.sp),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                          "(15%) < Masih Tahap Percobaan")
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: masuk.length,
                                        physics: const ClampingScrollPhysics(),
                                        itemBuilder: (context, absenIndex) {
                                          final absen = masuk[absenIndex];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                absen.absen,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Center(
                                                child: Wrap(
                                                  children: absen.options
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    int index = entry.key;
                                                    bool isCorrectAnswer = true;
                                                    if (index + 1 ==
                                                        absen.pilihanPertama) {
                                                      isCorrectAnswer = true;
                                                    } else if (index + 1 ==
                                                        absen.pilihanKedua) {
                                                      isCorrectAnswer = true;
                                                    }
                                                    bool isSelected =
                                                        selectedAbsensiIndex[
                                                                absenIndex] ==
                                                            index;
                                                    bool isAlreadyAnswered =
                                                        isMasuk[absenIndex];
                                                    return GestureDetector(
                                                      onTap: () => pickAbsensi(
                                                          absenIndex, index),
                                                      child: Container(
                                                        width: 200,
                                                        height: 50,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                    top: 5,
                                                                    bottom: 5,
                                                                    right: 40,
                                                                    left: 40)
                                                                .r,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSelected
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  214, 241, 252)
                                                              : Colors.grey
                                                                  .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0),
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade400,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Text(
                                                              entry.value,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      20.sp,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          );
                                        },
                                      ),
                                      // Score and Progress
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, right: 10).r,
                            child: Container(
                              color: const Color.fromARGB(255, 227, 226, 226),
                              height: 2.h,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              padding: const EdgeInsets.all(8).w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Penampilan",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.sp),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text("(5%) < Masih Tahap Percobaan")
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: penampilan.length,
                                        physics: const ClampingScrollPhysics(),
                                        itemBuilder:
                                            (context, penampilanIndex) {
                                          final tampilan =
                                              penampilan[penampilanIndex];
                                          return Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tampilan.tampilan,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10.h,
                                                ),
                                                Center(
                                                  child: Wrap(
                                                    children: tampilan.options
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry.key;
                                                      bool isCorrectAnswer =
                                                          true;
                                                      if (index + 1 ==
                                                          tampilan
                                                              .pilihanPertama) {
                                                        isCorrectAnswer = true;
                                                      } else if (index + 1 ==
                                                          tampilan
                                                              .pilihanKedua) {
                                                        isCorrectAnswer = true;
                                                      }
                                                      bool isSelected =
                                                          selectedPenampilanIndex[
                                                                  penampilanIndex] ==
                                                              index;
                                                      bool isAlreadyAnswered =
                                                          isPenampilan[
                                                              penampilanIndex];
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            pickAnswerPenampilan(
                                                                penampilanIndex,
                                                                index),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                      top: 5,
                                                                      bottom: 5,
                                                                      right: 40,
                                                                      left: 40)
                                                                  .r,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isSelected
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    214,
                                                                    241,
                                                                    252)
                                                                : Colors.grey
                                                                    .shade100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0),
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? Colors.blue
                                                                  : Colors.grey
                                                                      .shade400,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Text(
                                                                entry.value,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      // Score and Progress
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, right: 10).r,
                            child: Container(
                              color: const Color.fromARGB(255, 227, 226, 226),
                              height: 2.h,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          FinalCalculation(
                            currUser: widget.currUser,
                            score: score,
                            onScoreChanged: (newScore) {
                              setState(() {
                                score = newScore;
                              });
                            },
                            nilai: nilai,
                            onNilaiChanged: (newNilai) {
                              setState(() {
                                score = newNilai;
                              });
                            },
                            hadir: hadir,
                            onHadirChanged: (newHadir) {
                              setState(() {
                                score = newHadir;
                              });
                            },
                            skil: skil,
                            onSkilChanged: (newSkil) {
                              setState(() {
                                score = newSkil;
                              });
                            },
                            kerjabro: kerjabro,
                            onKerjaBroChanged: (newKerjaBro) {
                              setState(() {
                                score = newKerjaBro;
                              });
                            },
                            tampilann: tampilann,
                            onTampilannChanged: (newTampilanBro) {
                              setState(() {
                                score = newTampilanBro;
                              });
                            },
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Container(
                            color: const Color.fromARGB(255, 171, 167, 167),
                            height: 2.h,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: 330.h,
                            color: LightColors.kFagettiBlue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Text(
                                    "Legend :",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2.3, color: Colors.white),
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        "  0 - 1.99 Kurang",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30.w,
                                      ),
                                      Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2.3, color: Colors.white),
                                          color: const Color(0xFF5BA53B),
                                        ),
                                      ),
                                      Text(
                                        "  3 - 4 Bagus",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2.3, color: Colors.white),
                                          color: const Color(0xFFE69E00),
                                        ),
                                      ),
                                      Text(
                                        "  2 - 2.99 Cukup",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  const CustomAreaPernilaian(
                                    header: "Summary",
                                    textAreaName: "keterangan",
                                    hintText: "Optional...",
                                    isRequired: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    ();
                                  },
                                  child: const Text(
                                    'Save as draft',
                                    style: TextStyle(
                                        color: Color(0xFF585858),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    backgroundColor: LightColors.kFagettiBlue,
                                  ),
                                  onPressed: () {
                                    savePenilaian();
                                  },
                                  child: const Text(
                                    'Kirim',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
