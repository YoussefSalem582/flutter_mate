import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/controller/lesson_controller.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/lesson_repository.dart';
import 'package:flutter_mate/features/roadmap/data/services/progress_sync_service.dart';
import 'package:get/get.dart';

/// Provides dependencies for the progress tracker feature.
class ProgressTrackerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RoadmapRepository>()) {
      Get.lazyPut<RoadmapRepository>(() => RoadmapRepositoryImpl());
    }

    if (!Get.isRegistered<RoadmapController>()) {
      Get.lazyPut<RoadmapController>(
        () => RoadmapController(repository: Get.find<RoadmapRepository>()),
      );
    }

    if (!Get.isRegistered<ProgressSyncService>()) {
      Get.lazyPut<ProgressSyncService>(() => ProgressSyncService());
    }

    if (!Get.isRegistered<LessonRepository>()) {
      Get.lazyPut<LessonRepository>(
        () => LessonRepositoryImpl(Get.find<ProgressSyncService>()),
      );
    }

    if (!Get.isRegistered<LessonController>()) {
      Get.lazyPut<LessonController>(
        () => LessonController(Get.find<LessonRepository>()),
      );
    }

    Get.lazyPut<ProgressTrackerController>(
      () => ProgressTrackerController(
        roadmapController: Get.find<RoadmapController>(),
        lessonController: Get.find<LessonController>(),
      ),
    );
  }
}
