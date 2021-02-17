
import 'package:flutter/material.dart';

enum ScreenType { xl, lg, md, sm, xs }

ScreenType screenType (BuildContext context){
  var width = MediaQuery.of(context).size.width;
  if (width > 1200) {
    return ScreenType.xl;
  } else if (width > 992) {
    return ScreenType.lg;
  } else if (width > 768) {
    return ScreenType.md;
  } else if (width > 544) {
    return ScreenType.sm;
  } else {
    return ScreenType.xs;
  }
}
