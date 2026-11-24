import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/quiz_progress_store.dart';
import 'package:reelmind/main.dart';
import 'package:reelmind/models/learning_reel.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('User can swipe through learning reels', (tester) async {
    // Launch ReelMind.
    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    // Check the first educational reel.
    expect(find.text('Why is the sky blue?'), findsOneWidget);

    // Swipe up to the next reel.
    await tester.drag(find.byType(PageView), const Offset(0, -600));

    await tester.pumpAndSettle();

    // Check the second reel.
    expect(find.text('What is an API?'), findsOneWidget);
  });

  testWidgets('User can switch between Turkish and English', (tester) async {
    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    // Switch to Turkish.
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Türkçe').last);
    await tester.pumpAndSettle();

    expect(find.text('Gökyüzü neden mavidir?'), findsOneWidget);
    expect(find.text('Bilgini Test Et'), findsOneWidget);
    expect(find.byTooltip('Dersler'), findsOneWidget);

    // Switch back to English.
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Why is the sky blue?'), findsOneWidget);
    expect(find.text('Test Your Knowledge'), findsOneWidget);
  });

  testWidgets('Quiz shows correct and incorrect feedback', (tester) async {
    // Use a realistic mobile screen size.
    await tester.binding.setSurfaceSize(const Size(430, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    // Open the quiz.
    await tester.tap(find.text('Test Your Knowledge'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which color is scattered most strongly by air molecules?'),
      findsOneWidget,
    );

    // Select correct answer.
    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();

    expect(find.text('Correct!'), findsOneWidget);

    // Return to the feed.
    final backButton = find.text('Back to feed');

    await tester.ensureVisible(backButton);
    await tester.pumpAndSettle();

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.text('Why is the sky blue?'), findsOneWidget);

    // Reopen quiz and select incorrect answer.
    await tester.tap(find.text('Retry Quiz'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Red'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Not quite.'), findsOneWidget);

    // Correct answer should still be visible.
    expect(find.text('Blue'), findsOneWidget);
  });

  testWidgets('Unsubmitted quizzes leave progress unchanged', (tester) async {
    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    expect(find.text('Answered 0/3 · Correct 0/3'), findsOneWidget);
    expect(find.text('Unanswered'), findsOneWidget);
    await tester.tap(find.text('Test Your Knowledge'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Answered 0/3 · Correct 0/3'), findsOneWidget);
    expect(find.text('Unanswered'), findsOneWidget);
    expect(await QuizProgressStore().load(), isEmpty);
  });

  testWidgets(
    'Restores progress and replaces the same lesson across languages',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'reelmind.quizResult.removed-lesson': true,
          });

      await tester.pumpWidget(const ReelMindApp());
      await tester.pumpAndSettle();
      expect(find.text('Answered 0/3 · Correct 0/3'), findsOneWidget);

      await tester.tap(find.text('Test Your Knowledge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Answered 1/3 · Correct 1/3'), findsOneWidget);
      expect(find.text('Answered correctly'), findsOneWidget);

      await tester.tap(find.byKey(const Key('language-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Türkçe').last);
      await tester.pumpAndSettle();

      expect(find.text('Yanıtlanan 1/3 · Doğru 1/3'), findsOneWidget);
      expect(find.text('Doğru yanıtlandı'), findsOneWidget);

      await tester.tap(find.text('Testi Tekrar Çöz'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kırmızı'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Yanıtlanan 1/3 · Doğru 0/3'), findsOneWidget);
      expect(find.text('Yanlış yanıtlandı'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('Yanıtlanmadı'), findsOneWidget);
      expect(find.text('Yanıtlanan 1/3 · Doğru 0/3'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const ReelMindApp());
      await tester.pumpAndSettle();

      expect(find.text('Answered 1/3 · Correct 0/3'), findsOneWidget);
      expect(find.text('Answered incorrectly'), findsOneWidget);
      expect(await QuizProgressStore().load(), {LessonId.skyColor: false});
    },
  );

  testWidgets('Lesson list shows saved results and jumps to a lesson', (
    tester,
  ) async {
    final store = QuizProgressStore();
    await store.save(LessonId.skyColor, isCorrect: true);
    await store.save(LessonId.apiIntro, isCorrect: false);

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lessons'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    Finder inSheet(String text) =>
        find.descendant(of: sheet, matching: find.text(text));

    expect(inSheet('Answered correctly'), findsOneWidget);
    expect(inSheet('Answered incorrectly'), findsOneWidget);
    expect(inSheet('Unanswered'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(
            find.ancestor(
              of: inSheet('Why is the sky blue?'),
              matching: find.byType(ListTile),
            ),
          )
          .selected,
      isTrue,
    );

    await tester.tap(inSheet('What is an API?'));
    await tester.pumpAndSettle();

    expect(sheet, findsNothing);
    expect(find.text('What is an API?'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('Answered incorrectly'), findsOneWidget);

    await tester.tap(find.byTooltip('Lessons'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(inSheet('Unanswered'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('Feed does not overflow on small phones', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    expect(find.text('Why is the sky blue?'), findsOneWidget);

    // Detect Flutter layout exceptions.
    expect(tester.takeException(), isNull);
  });
}
