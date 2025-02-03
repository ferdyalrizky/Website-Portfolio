import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MenuBtn extends StatelessWidget {
  const MenuBtn({
    super.key,
    required this.press,
    required this.riveOnInit,
  });

  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: press,
            child: Container(
                margin: const EdgeInsets.only(right: 16, top: 23, bottom: 23),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0xFF585858), width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: RiveAnimation.asset(
                  "assets/Riveasset/menu_button.riv",
                  onInit: riveOnInit,
                )),
          ),
        ],
      ),
    );
  }
}
