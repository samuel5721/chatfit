import 'package:flutter/material.dart';

class KeyColor {
  static Color primaryDark100 = const Color(0xff33374E);
  static Color primaryDark200 = const Color(0xff252737);
  static Color primaryDark300 = const Color(0xff1B1D29);

  static Color primaryBrand100 = const Color(0xffFF8C66);
  static Color primaryBrand200 = const Color(0xffAA6554);
  static Color primaryBrand300 = const Color(0xffFF3F00);

  static Color grey100 = const Color(0xffFDFEFE);
  static Color grey200 = const Color(0xffF4F5F5);
  static Color grey300 = const Color(0xffEAEBEB);
  static Color grey400 = const Color(0xffDADDDD);
  static Color grey500 = const Color(0xffB4B9B9);
  static Color grey600 = const Color(0xff808989);
  static Color grey700 = const Color(0xff626A6B);
  static Color grey800 = const Color(0xff4B5152);
  static Color grey900 = const Color(0xff333738);
  static Color grey1000 = const Color(0xff1C1F1F);
}

class Layout {
  static double entireWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double entireHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double headerHeight(BuildContext context) {
    return entireHeight(context) * 0.1;
  }

  static double navigationBarHeight(BuildContext context) {
    return entireHeight(context) * 0.1;
  }

  static double bodyHeight(BuildContext context) {
    return entireHeight(context) -
        headerHeight(context) -
        navigationBarHeight(context);
  }
}
