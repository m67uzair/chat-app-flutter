import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final Icon icon;
  bool obscureText = true;
  TextInputType keyboardType;
  Widget? label;
  final String? Function(String? value) validator;

  final TextEditingController controller;
  IconData suffixIcon = Icons.visibility;
  CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.label,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.hintText.toLowerCase() == "password"
          ? widget.obscureText
          : false,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black12,
          ),
        ),
        hintText: widget.hintText,
        label: widget.label,
        hintStyle: const TextStyle(
          color: Colors.black38,
        ),
        icon: widget.icon,
        suffixIcon: widget.hintText.toLowerCase() == "password"
            ? InkWell(
                child: Icon(widget.suffixIcon),
                onTap: () {
                  setState(() {
                    widget.obscureText =
                        widget.obscureText == true ? false : true;
                    widget.suffixIcon = widget.suffixIcon == Icons.visibility
                        ? Icons.visibility_off
                        : Icons.visibility;
                  });
                },
              )
            : null,
      ),
    );
  }
}
