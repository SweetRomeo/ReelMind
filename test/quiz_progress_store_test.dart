import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/quiz_progress_store.dart';
import 'package:reelmind/models/learning_reel.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('An empty store restores no results', () async {
    expect(await QuizProgressStore().load(), isEmpty);
  });

  test('A new store restores the latest result for each lesson', () async {
    final store = QuizProgressStore();
    await Future.wait([
      store.save(LessonId.skyColor, isCorrect: true),
      store.save(LessonId.apiIntro, isCorrect: true),
    ]);
    await store.save(LessonId.skyColor, isCorrect: false);

    expect(await QuizProgressStore().load(), {
      LessonId.skyColor: false,
      LessonId.apiIntro: true,
    });
  });
}
