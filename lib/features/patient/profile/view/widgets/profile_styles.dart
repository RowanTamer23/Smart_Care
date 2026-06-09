import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF16302B);
  static const primaryMid = Color(0xFF1F4035);
  static const teal = Color(0xFF0F9B8E);
  static const tealLight = Color(0xFFCCF5F2);
  static const amber = Color(0xFFF5A623);
  static const amberLight = Color(0xFFFFF3DC);
  static const red = Color(0xFFDC3545);
  static const redLight = Color(0xFFFFEBED);
  static const green = Color(0xFF1A9E6A);
  static const greenLight = Color(0xFFD6F5E8);
  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFFDCEBFE);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFEDE9FE);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFEDD5);
  static const border = Color(0xFFE4E8F0);
  static const txt1 = Color(0xFF0D1B2A);
  static const txt2 = Color(0xFF536070);
  static const txt3 = Color(0xFF9BAAB8);
}

TextStyle hTextStyle(double s, {Color? c, FontWeight? w, double? ls}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w700,
      color: c ?? C.txt1,
      letterSpacing: ls ?? -0.3,
      height: 1.2,
    );

TextStyle bTextStyle(double s, {Color? c, FontWeight? w}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w400,
      color: c ?? C.txt1,
      height: 1.5,
    );

TextStyle lblTextStyle({Color? c, double s = 11, FontWeight? w}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w600,
      color: c ?? C.txt3,
      letterSpacing: 0.5,
    );
