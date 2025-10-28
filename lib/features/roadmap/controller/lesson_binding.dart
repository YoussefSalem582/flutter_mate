import 'package:get/get.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/video_tutorial_repository.dart';
import '../data/services/progress_sync_service.dart';
import 'lesson_controller.dart';

class LessonBinding extends Bindings {
  @override
  void dependencies() {
    // Register ProgressSyncService
    Get.lazyPut<ProgressSyncService>(() => ProgressSyncService());

    Get.lazyPut<LessonRepository>(
      () => LessonRepositoryImpl(Get.find<ProgressSyncService>()),
    );

    Get.lazyPut<VideoTutorialRepository>(() => VideoTutorialRepositoryImpl());

    Get.lazyPut<LessonController>(
      () => LessonController(Get.find<LessonRepository>()),
    );
  }
}
