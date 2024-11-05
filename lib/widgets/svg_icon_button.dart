import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconButton extends StatelessWidget {
  const SvgIconButton({
    super.key,
    required this.size,
    required this.onPressed,
    required this.iconPath,
  });

  final double size;
  final String iconPath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          iconPath,
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
