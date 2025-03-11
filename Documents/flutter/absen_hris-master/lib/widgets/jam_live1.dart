import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ClockWidgetAbsen extends StatefulWidget {
  const ClockWidgetAbsen({super.key});

  @override
  _ClockWidgetAbsenState createState() => _ClockWidgetAbsenState();
}

class _ClockWidgetAbsenState extends State<ClockWidgetAbsen> {
  Timer? _timer;
  tz.TZDateTime? _currentTime;
  String _location = 'Asia/Jakarta'; // lokasi default
  final List<String> _locations = ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'];

  String getZone(String location) {
    switch (location) {
      case 'Asia/Jakarta':
        return 'WIB';
      case 'Asia/Makassar':
        return 'WITA';
      case 'Asia/Jayapura':
        return 'WIT';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _currentTime = tz.TZDateTime.now(tz.getLocation(_location));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = tz.TZDateTime.now(tz.getLocation(_location));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _changeLocation(String location) {
    setState(() {
      _location = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat('HH:mm', 'id_ID').format(_currentTime!),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 31.sp,
          ),
        ),
      ],
    );
  }
}
