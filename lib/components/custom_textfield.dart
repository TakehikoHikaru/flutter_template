import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield extends StatefulWidget {
  String label;
  String hint;
  String? Function(String?)? validator;
  TextEditingController controller;
  bool readOnly;
  TextInputType keyboardType;
  TextInputFormatter? inputFormatter;
  CustomTextfield({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatter,
    super.key,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        label: Text(widget.label),
        hintText: widget.hint,
      ),
      validator: widget.validator,
      inputFormatters: [
        if (widget.inputFormatter != null) widget.inputFormatter!
      ],
      readOnly: false,
      keyboardType: widget.keyboardType,
    );
  }
}
