import 'package:flutter/material.dart';

class ButtonWithLoader extends StatelessWidget {
  final String text;
  final String loadingText;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ButtonWithLoader({
    super.key,
    required this.text,
    required this.loadingText,
    this.isLoading = false,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          Text(isLoading ? loadingText : text),
        ],
      ),
    );
  }
}
