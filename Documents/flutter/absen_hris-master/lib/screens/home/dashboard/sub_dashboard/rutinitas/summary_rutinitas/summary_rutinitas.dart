import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/aktifitas.dart';
import 'package:hris_v2/models/meeting.dart';
import 'package:hris_v2/models/pertemuan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/list/list_aktifitas.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/rutinitas/summary_rutinitas/list/list_pertemuan.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../models/karyawan.dart';
import '../../../../../../widgets/loader.dart';

class SummaryRutinitasScreen extends StatefulWidget {
  final Karyawan currUser;
  final List<Meeting> meeting;
  final List<Aktifitas> aktifitas;
  const SummaryRutinitasScreen({
    super.key,
    required this.meeting,
    required this.aktifitas,
    required this.currUser,
  });

  @override
  State<SummaryRutinitasScreen> createState() => _SummaryRutinitasScreenState();
}

class _SummaryRutinitasScreenState extends State<SummaryRutinitasScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDay;
  DateTime today = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  DateTime _focusedYear = DateTime.now();
  bool isLoadingSetInitialData = true;
  List<Meeting> listmeetingSelectedDate = [];
  List<Aktifitas> ListAktifitasSelectedDate = [];
  CalendarFormat _calendarFormat = CalendarFormat.week;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    _setListLemburSelectedDate();
    _setListAktifitasSelectedDate();
    _tabController = TabController(
        length: 2, vsync: this); // Adjust the length based on your tabs
  }

  void _onDaySelected(day, focusedDay) async {
    setState(() {
      isLoadingSetInitialData = true;
      today = day;
      _focusedMonth = focusedDay;
      _focusedYear = focusedDay;
    });

    await _setListLemburSelectedDate();
    await _setListAktifitasSelectedDate();
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFFB000), // primary color
                secondary: Color(0xFFFFEFBD),
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      setState(() {
        isLoadingSetInitialData = true;
        today = picked;
      });

      await _setListLemburSelectedDate();
      await _setListAktifitasSelectedDate();
    }
  }

  _setListLemburSelectedDate() async {
    listmeetingSelectedDate = [];
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);

    for (var i = 0; i < widget.meeting.length; i++) {
      Meeting selectedMeeting = widget.meeting[i];
      String selectedDateLembur =
          DateFormat('yyyy-MM-dd').format((selectedMeeting.tglPertemuan));

      if (selectedDateLembur == formattedToday) {
        listmeetingSelectedDate.add(selectedMeeting);
      }
    }

    setState(() {
      isLoadingSetInitialData = false;
    });
  }

  _setListAktifitasSelectedDate() async {
    ListAktifitasSelectedDate = [];
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);

    for (var i = 0; i < widget.meeting.length; i++) {
      Aktifitas selectedAktifitas = widget.aktifitas[i];
      String selectedDateAktifitas =
          DateFormat('yyyy-MM-dd').format((selectedAktifitas.tglMulai));

      if (selectedDateAktifitas == formattedToday) {
        ListAktifitasSelectedDate.add(selectedAktifitas);
      }
    }

    setState(() {
      isLoadingSetInitialData = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: false,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            expandedHeight: 5000,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 52),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 18),
                            child: Text(
                              DateFormat('MMMM').format(_focusedMonth),
                              style: const TextStyle(
                                color: Color(0xFF121212),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              DateFormat('y').format(_focusedYear),
                              style: const TextStyle(
                                color: Color(0xFF121212),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<CalendarFormat>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: Colors.white,
                        onSelected: (CalendarFormat format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        offset: Offset(-50, 50),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<CalendarFormat>>[
                          PopupMenuItem<CalendarFormat>(
                            value: CalendarFormat.week,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _calendarFormat == CalendarFormat.week
                                    ? Color(0xFFE6F1F8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/minggu.svg",
                                    color:
                                        _calendarFormat == CalendarFormat.week
                                            ? Colors.black
                                            : Color(0xFF717171),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 11),
                                    child: Text(
                                      "Minggu",
                                      style: TextStyle(
                                        color: _calendarFormat ==
                                                CalendarFormat.week
                                            ? Colors.black
                                            : Color(0xFF717171),
                                        fontWeight: _calendarFormat ==
                                                CalendarFormat.week
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.only(
                                      right: 20, top: 10, bottom: 10, left: 20)
                                  .r,
                            ),
                          ),
                          PopupMenuItem<CalendarFormat>(
                            value: CalendarFormat.month,
                            child: Container(
                              color: _calendarFormat == CalendarFormat.month
                                  ? Color(0xFFE6F1F8)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/bulan.svg",
                                    color:
                                        _calendarFormat == CalendarFormat.month
                                            ? Colors.black
                                            : Color(0xFF717171),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      "Bulan",
                                      style: TextStyle(
                                        color: _calendarFormat ==
                                                CalendarFormat.month
                                            ? Colors.black
                                            : Color(0xFF717171),
                                        fontWeight: _calendarFormat ==
                                                CalendarFormat.month
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.only(
                                      right: 20, top: 10, bottom: 10, left: 20)
                                  .r,
                            ),
                          ),
                        ],
                        child: TextButton(
                          onPressed: null, // No need for onPressed here
                          child: _calendarFormat == CalendarFormat.month
                              ? SvgPicture.asset("assets/images/bulan.svg")
                              : SvgPicture.asset("assets/images/minggu.svg"),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 400,
                    child: TableCalendar(
                      firstDay: DateTime(today.year, DateTime.january),
                      lastDay: DateTime(today.year, DateTime.december, 31),
                      focusedDay: today,
                      calendarFormat: _calendarFormat,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      rowHeight: 60.h, // Increase row height for larger cells
                      availableGestures: AvailableGestures.all,
                      onDaySelected: _onDaySelected,
                      selectedDayPredicate: (day) {
                        return isSameDay(today, day);
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        today = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: const Color(
                              0xFF121212), // Background color for today
                          shape: BoxShape.circle, // Circular shape
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, _) {
                          return Container(
                            width: 50.w, // Increase width for selected day
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF121212),
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, date, _) {
                          return Container(
                            width: 50.w, // Increase width for today
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7E7E7),
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        markerBuilder: (context, date, events) {
                          bool hasLemburOnDate =
                              listmeetingSelectedDate.any((lembur) {
                            DateTime? lemburDate = lembur.tglPertemuan != null
                                ? lembur.tglPertemuan
                                : null;
                            return lemburDate != null &&
                                isSameDay(lemburDate, date);
                          });

                          bool aktifitashas =
                              ListAktifitasSelectedDate.any((aktifitas) {
                            DateTime? AktifitasDate = aktifitas.tglMulai != null
                                ? aktifitas.tglMulai
                                : null;
                            return AktifitasDate != null &&
                                isSameDay(AktifitasDate, date);
                          });

                          bool isAktifitasTab = _tabController.index == 0;
                          Color markerColor = isAktifitasTab
                              ? (aktifitashas
                                  ? Colors.blue
                                  : Colors.grey) // Hanya tampilkan aktivitas
                              : (hasLemburOnDate ? Colors.yellow : Colors.grey);

                          return Positioned(
                            bottom: 0,
                            top: 30,
                            child: Container(
                              width: 10, // Increase marker size
                              height: 10, // Increase marker size
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                      daysOfWeekVisible: true,
                    ),
                  ),
                  SizedBox(height: 20.h), // Space between calendar and tabs
                  TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2, color: Colors.black),
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF585858),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    labelColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Aktifitas'),
                      Tab(text: 'Pertemuan'),
                    ],
                  ),
                  Expanded(
                    child: isLoadingSetInitialData
                        ? const Center(child: Loader())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              tabBiayaDiriSendiri(),
                              tabBiaya(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SafeArea tabBiayaDiriSendiri() {
    print(
        'Rendering tabBiayaDiriSendiri with ${ListAktifitasSelectedDate.length} items');
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ListAktifitasSelectedDate.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return AktifitasCard(
                  aktifitas: ListAktifitasSelectedDate[index],
                  currUser: widget.currUser,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SafeArea tabBiaya() {
    print('Rendering tabBiaya with ${listmeetingSelectedDate.length} items');
    return SafeArea(
      child: ListPertemuan(
        meetings: listmeetingSelectedDate, // Pass the entire list of meetings
        currUser: widget.currUser,
      ),
    );
  }
}
