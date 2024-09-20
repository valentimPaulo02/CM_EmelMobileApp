import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.textSize = 18,
    this.icon,
    this.iconSize,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
    this.onPressed,
  });

  final String text;
  final double textSize;
  final IconData? icon;
  final double? iconSize;
  final Color? color;
  final EdgeInsets padding;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    Color btnColor = color ?? Theme.of(context).colorScheme.primary;

    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          surfaceTintColor: MaterialStateProperty.all(const Color(0xFF4A525E)),
          backgroundColor: onPressed != null
              ? MaterialStateProperty.all(const Color(0xFF4A525E))
              : MaterialStateProperty.all(const Color(0xFF434b56)),
          overlayColor: MaterialStateProperty.all(color?.withOpacity(0.25)),
          padding: MaterialStateProperty.all(padding),
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return 0; // No elevation when pressed
              }
              return 4; // Default elevation when not pressed
            },
          ),
        ),
        child: Row(
          children: [
            icon != null
                ? Icon(icon, size: iconSize, color: btnColor)
                : const SizedBox(width: 0),
            SizedBox(
              width: icon != null ? 4 : 0,
            ),
            Text(
              text,
              style: TextStyle(
                color: onPressed != null ? btnColor : btnColor.withOpacity(0.4),
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ));
  }
}
