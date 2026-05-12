import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/image_lab/presentation/screens/image_lab_screen.dart';
import 'features/image_lab/presentation/screens/onboarding_screen.dart';
import 'features/image_lab/theme/app_colors.dart';
import 'features/image_lab/theme/app_radii.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(ImageFiltersLabApp(onboardingCompleted: onboardingCompleted));

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class ImageFiltersLabApp extends StatelessWidget {
  final bool onboardingCompleted;

  const ImageFiltersLabApp({
    super.key,
    required this.onboardingCompleted,
  });

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
            minimumSize: const Size.fromHeight(52),
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
      home: onboardingCompleted ? const ImageLabScreen() : const OnboardingScreen(),
    );
  }
}
