import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../../../../widgets/top_container.dart';

class ProfileBannerRow extends StatelessWidget {
  const ProfileBannerRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TopContainer(
      height: getPropotionateScreenHeight(100),
      width: SizeConfig.screenWidth,
      bottomLeftRadius: const Radius.circular(0),
      bottomRightRadius: const Radius.circular(0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              //Circle Avatar
              CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 35.0,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
              SizedBox(width: 20),
              //Detail Profile
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ferdy Al Rizky", //Nama
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "0993", //NIP
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Mobile App Developer", //Job Title
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
