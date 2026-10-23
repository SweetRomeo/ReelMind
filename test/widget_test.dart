
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/main.dart';

void main() {
  testWidgets('User can swipe through learning reels', (tester) async {
    // Launch ReelMind.
    await tester.pumpWidget(const ReelMindApp());

    // Check the first educational reel.
    expect(find.text('Why is the sky blue?'), findsOneWidget);

    // Swipe up to the next reel.
    await tester.drag(
      find.byType(PageView),
      const Offset(0, -600),
    );

    await tester.pumpAndSettle();

    // Check the second reel.
    expect(find.text('What is an API?'), findsOneWidget);
  });
  
testWidgets('User can switch between Turkish and English',
    (tester) async {
  await tester.pumpWidget(const ReelMindApp());
  await tester.pumpAndSettle();

  // Switch to Turkish.
  await tester.tap(find.byKey(const Key('language-menu')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Türkçe').last);
  await tester.pumpAndSettle();

  expect(find.text('Gökyüzü neden mavidir?'), findsOneWidget);
  expect(find.text('Bilgini Test Et'), findsOneWidget);

  // Switch back to English.
  await tester.tap(find.byKey(const Key('language-menu')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('English').last);
  await tester.pumpAndSettle();

  expect(find.text('Why is the sky blue?'), findsOneWidget);
  expect(find.text('Test Your Knowledge'), findsOneWidget);
});

}

