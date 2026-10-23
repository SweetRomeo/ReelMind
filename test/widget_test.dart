
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
}
