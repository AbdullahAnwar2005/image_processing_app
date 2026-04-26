import 'package:flutter/material.dart';
import 'features/image_lab/presentation/screens/image_lab_screen.dart';
import 'features/image_lab/theme/app_colors.dart';
import 'features/image_lab/theme/app_radii.dart';

void main() {
  runApp(const ImageFiltersLabApp());
}

class ImageFiltersLabApp extends StatelessWidget {
  const ImageFiltersLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Filters Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: null, // Use system default
        
        // Custom button themes
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.primaryButton),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        
        // Slider theme
        sliderTheme: SliderThemeData(
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.divider,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withOpacity(0.12),
        ),
      ),
      home: const ImageLabScreen(),
    );
  }
}
