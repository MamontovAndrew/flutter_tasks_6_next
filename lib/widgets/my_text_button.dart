import 'package:flutter/material.dart';
import '../res/dimentions.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.width,
  });

  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor:
        MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppDimens.radiusMedium),
        )),
      ),
      child: SizedBox(
        width: width,
        child: Center(
          child: Text(
            text,
            style: textStyle?.copyWith(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ),
    );
  }
}
