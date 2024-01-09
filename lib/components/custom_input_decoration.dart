import 'package:flutter/material.dart';

InputDecoration customInputDecoration({
  String? labelText,
  TextStyle? labelStyle,
  Color? fillColor,
  Icon? suffixIcon,
  bool? isDense,
  EdgeInsetsGeometry? contentPadding,
  TextStyle? floatingLabelStyle,
  String? helperText,
  int? helperMaxLines,
  String? hintText,
  TextStyle? hintStyle,
  InputBorder? border,
  InputBorder? focusedBorder,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: labelStyle ?? const TextStyle(color: Colors.black),
    helperText: helperText,
    helperMaxLines: helperMaxLines,
    hintText: hintText,
    hintStyle: hintStyle,
    fillColor: fillColor ?? Colors.white,
    filled: true,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    focusedBorder: focusedBorder ?? const OutlineInputBorder(
      borderSide: BorderSide(width: 1.5),
    ),
    border: border ??
        const OutlineInputBorder(
          borderSide: BorderSide(width: 1),
        ),
    isDense: isDense,
    contentPadding: contentPadding,
    floatingLabelStyle: floatingLabelStyle,
    errorMaxLines: 3,
  );
}
