import 'package:flutter/material.dart';

class ClickableText extends StatefulWidget {
  Function onPressed;
  String text;
  ClickableText({
    required this.onPressed,
    required this.text,
    super.key,
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onPressed(),
      child: Text(
        widget.text,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue
        ),
      ),
    );
  }
}
