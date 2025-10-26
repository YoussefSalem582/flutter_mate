import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/lesson_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

/// Provides dependencies for roadmap related pages.
class RoadmapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoadmapRepository>(() => RoadmapRepositoryImpl());

    // Try to get lesson repository if it exists
    LessonRepository? lessonRepo;
    try {
      if (Get.isRegistered<LessonRepository>()) {
        lessonRepo = Get.find<LessonRepository>();
      } else {
        lessonRepo = LessonRepositoryImpl(Get.find<SharedPreferences>());
        Get.put<LessonRepository>(lessonRepo);
      }
    } catch (e) {
      lessonRepo = null;
    }

    Get.lazyPut<RoadmapController>(
      () => RoadmapController(
        repository: Get.find<RoadmapRepository>(),
        lessonRepository: lessonRepo,
      ),
    );
  }
}
