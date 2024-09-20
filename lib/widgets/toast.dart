import 'package:flutter/material.dart';

enum ToastAlignment {
  top,
  bottom,
}

class Toast {
  static void triggerToast(
    BuildContext context,
    String text,
    bool success,
    ToastAlignment? alignment,
    Duration? duration,
    void Function()? afterToast,
  ) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        text: text,
        success: success,
        alignment: alignment ?? ToastAlignment.bottom,
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(
      duration ?? const Duration(seconds: 2, milliseconds: 500),
      () {
        overlayEntry.remove();
        if (afterToast != null) afterToast();
      },
    );
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({
    required this.text,
    required this.success,
    this.alignment = ToastAlignment.bottom,
  });

  final String text;
  final bool success;
  final ToastAlignment alignment;

  @override
  Widget build(BuildContext context) {
    Color successBg = const Color(0xFF3CCD6A);
    Color successFg = const Color(0xFF377D4D);
    Color failureBg = const Color(0xFFC34646);
    Color failureFg = const Color(0xFF420A0A);

    return Positioned(
      top: alignment == ToastAlignment.top ? 145 : null,
      bottom: alignment == ToastAlignment.bottom ? 120 : null,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: IntrinsicWidth(
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 250,
                maxWidth: 350,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: success ? successBg : failureBg,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 30,
                    color: success ? successFg : failureFg,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: success ? successFg : failureFg,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
