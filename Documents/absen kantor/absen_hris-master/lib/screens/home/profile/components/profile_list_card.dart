import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? press;
  const ProfileListCard({
    super.key,
    required this.title,
    required this.icon,
    this.press,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(
              height: 8.h,
            ),
            Row(
              children: [
                FaIcon(
                  icon,
                  size: 30.w,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ],
            ),
            Container(
              color: const Color(0xFFDBDBDB),
              height: 1.w,
              width: double.infinity,
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }
}
