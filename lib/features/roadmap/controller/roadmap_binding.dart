import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/lesson_repository.dart';
import 'package:flutter_mate/features/roadmap/data/services/progress_sync_service.dart';
import 'package:get/get.dart';

/// Provides dependencies for roadmap related pages.
class RoadmapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoadmapRepository>(() => RoadmapRepositoryImpl());

    // Register ProgressSyncService if not already registered
    if (!Get.isRegistered<ProgressSyncService>()) {
      Get.lazyPut<ProgressSyncService>(() => ProgressSyncService());
    }

    // Try to get lesson repository if it exists
    LessonRepository? lessonRepo;
    try {
      if (Get.isRegistered<LessonRepository>()) {
        lessonRepo = Get.find<LessonRepository>();
      } else {
        lessonRepo = LessonRepositoryImpl(Get.find<ProgressSyncService>());
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
