import 'package:artisans_circle/core/widgets/youtube_video_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Use an invalid URL so the widget shows the error state without creating a WebView.
  const invalidUrl = 'https://example.com/not-a-youtube-url';

  Future<void> pumpHost(WidgetTester tester, {VoidCallback? onClose}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showYouTubeVideoPopup(
                      context,
                      videoUrl: invalidUrl,
                      title: 'Test Title',
                      onClose: onClose,
                      barrierDismissible: false,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );
    // Open the dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Continue button closes the popup and calls onClose',
      (tester) async {
    var closed = false;
    await pumpHost(tester, onClose: () => closed = true);

    // Ensure dialog is visible
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Continue to App'), findsOneWidget);

    // Tap the Continue button
    await tester.tap(find.text('Continue to App'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and callback invoked
    expect(find.text('Test Title'), findsNothing);
    expect(closed, isTrue);
  });

  testWidgets('Close icon dismisses the popup and calls onClose',
      (tester) async {
    var closed = false;
    await pumpHost(tester, onClose: () => closed = true);

    // Tap the close icon button (Icons.close)
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // Dialog should be dismissed and callback invoked
    expect(find.byIcon(Icons.close), findsNothing);
    expect(closed, isTrue);
  });
}
