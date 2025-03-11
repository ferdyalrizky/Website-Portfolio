import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class KTimeLineStep extends StatelessWidget {
  const KTimeLineStep({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isMiddle,
    required this.idx,
    required this.text,
    required this.color,
    required this.warna,
    required this.date,
    required this.time,
  });

  final String text, date, time;
  final Color color;
  final Color warna;
  final bool isFirst, isLast, isMiddle;
  final int idx;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.2,
              isFirst: isFirst,
              isLast: isLast,
              beforeLineStyle: LineStyle(
                color: idx <= 1 ? Colors.grey : Colors.grey,
                thickness: 1,
              ),
              afterLineStyle: LineStyle(
                color: isLast ? Colors.grey : Colors.grey,
                thickness: 1,
              ),
              indicatorStyle: IndicatorStyle(
                width: 20.w,
                color: warna,
              ),
              endChild: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minHeight: 70),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isLast ? color : color,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              startChild: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // o MainAxisAlignment.start
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: date),
                          const TextSpan(
                              text:
                                  ' '), // espasyong nakapaloob sa dalawang text
                          TextSpan(text: time),
                        ],
                      ),
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
