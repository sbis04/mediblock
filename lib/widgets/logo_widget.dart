import 'package:flutter/material.dart';
import 'package:mediblock/res/custom_colors.dart';

class LogoWidget extends StatelessWidget {
  final double textSize;

  const LogoWidget({@required this.textSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          color: CustomColors.yellow,
          fontSize: textSize,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: 'edi',
            style: TextStyle(
              color: CustomColors.yellow.withOpacity(0.8),
              fontSize: textSize,
            ),
          ),
          TextSpan(
            text: 'B',
            style: TextStyle(
              color: CustomColors.blue,
              fontSize: textSize,
            ),
          ),
          TextSpan(
            text: 'lock',
            style: TextStyle(
              color: CustomColors.blue.withOpacity(0.8),
              fontSize: textSize,
            ),
          ),
        ],
      ),
    );
  }
}
