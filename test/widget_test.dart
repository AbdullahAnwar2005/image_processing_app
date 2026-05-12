import 'package:flutter_test/flutter_test.dart';
import 'package:image_processing_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ImageFiltersLabApp(onboardingCompleted: true));

    // Verify that the app starts (Workspace or Landing depending on state)
    // For now we just check if it builds without crashing.
    expect(find.byType(ImageFiltersLabApp), findsOneWidget);
  });
}
