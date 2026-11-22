import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_reel.dart';

class QuizProgressStore {
  final _preferences = SharedPreferencesAsync();

  Future<Map<LessonId, bool>> load() async {
    final preferences = await _preferences.getAll(
      allowList: {for (final id in LessonId.values) _key(id)},
    );
    return {
      for (final id in LessonId.values)
        if (preferences[_key(id)] case final bool isCorrect) id: isCorrect,
    };
  }

  Future<void> save(LessonId lessonId, {required bool isCorrect}) {
    return _preferences.setBool(_key(lessonId), isCorrect);
  }

  static String _key(LessonId id) => 'reelmind.quizResult.${id.storageId}';
}
