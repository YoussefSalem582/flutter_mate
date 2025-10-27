import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/video_tutorial_repository.dart';
import 'lesson_controller.dart';

class LessonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LessonRepository>(
      () => LessonRepositoryImpl(Get.find<SharedPreferences>()),
    );

    Get.lazyPut<VideoTutorialRepository>(() => VideoTutorialRepositoryImpl());

    Get.lazyPut<LessonController>(
      () => LessonController(Get.find<LessonRepository>()),
    );
  }
}
