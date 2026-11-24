import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/language_preference_store.dart';
import 'package:reelmind/data/quiz_progress_store.dart';
import 'package:reelmind/models/learning_reel.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  test(
    'Restores language choices and removes only the system override',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final store = LanguagePreferenceStore();
      final progress = QuizProgressStore();
      await progress.save(LessonId.skyColor, isCorrect: true);

      expect(await store.load(), isNull);
      for (final locale in [const Locale('tr'), const Locale('en')]) {
        await store.save(locale);
        expect(await LanguagePreferenceStore().load(), locale);
      }

      await store.save(null);
      expect(await LanguagePreferenceStore().load(), isNull);
      expect(await progress.load(), {LessonId.skyColor: true});
    },
  );

  test(
    'Unknown and malformed preferences fall back to the system language',
    () async {
      for (final value in <Object>['de', '', 42]) {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              'reelmind.language': value,
            });

        expect(await LanguagePreferenceStore().load(), isNull);
      }
    },
  );
}
