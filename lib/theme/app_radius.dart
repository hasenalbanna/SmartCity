import 'package:flutter/widgets.dart';

/// Shape & border-radius scale for Smart City.
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double pill = 999.0;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}

