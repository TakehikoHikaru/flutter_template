import 'package:flutter/material.dart';

class CustomButtom extends StatefulWidget {
  Function onPressed;
  String? text;
  IconData? icon;
  double? borderRadius;
  double? width;
  double? height;
  bool deavited;
  CustomButtom({
    required this.onPressed,
    this.text,
    this.icon,
    this.borderRadius,
    this.width = 150,
    this.height = 40,
    this.deavited = false,
    super.key,
  });

  @override
  State<CustomButtom> createState() => _CustomButtomState();
}

class _CustomButtomState extends State<CustomButtom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.deavited ? null : () => widget.onPressed(),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor:
              WidgetStateProperty.all(
                widget.deavited ? Colors.grey[300] :
                Theme.of(context).primaryColor),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8))),
        ),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.icon != null)
              Icon(
                widget.icon,
                color: Colors.white,
              ),
            if (widget.text != null)
              Text(
                widget.text!,
                style: TextStyle(color: Colors.white),
              )
          ],
        ),
      ),
    );
  }
}
