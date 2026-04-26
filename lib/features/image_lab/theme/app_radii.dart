import 'package:flutter/material.dart';

class AppRadii {
  static const double card = 24.0;
  static const double heroCard = 24.0;
  static const double primaryButton = 16.0;
  static const double iconButton = 12.0;
  static const double imagePreview = 24.0;
  static const double chip = 999.0;
  static const double segmentedOuter = 16.0;
  static const double segmentedInner = 12.0;
  static const double statRow = 16.0;
  static const double sliderThumb = 10.0;

  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get heroCardRadius => BorderRadius.circular(heroCard);
  static BorderRadius get primaryButtonRadius =>
      BorderRadius.circular(primaryButton);
  static BorderRadius get iconButtonRadius => BorderRadius.circular(iconButton);
  static BorderRadius get imagePreviewRadius =>
      BorderRadius.circular(imagePreview);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get segmentedOuterRadius =>
      BorderRadius.circular(segmentedOuter);
  static BorderRadius get segmentedInnerRadius =>
      BorderRadius.circular(segmentedInner);
  static BorderRadius get statRowRadius => BorderRadius.circular(statRow);
}
