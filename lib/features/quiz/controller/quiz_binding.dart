import 'package:get/get.dart';
import '../controller/quiz_controller.dart';

/// Dependency injection for QuizController
class QuizBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put to immediately create the controller
    // This ensures the controller is initialized with arguments before the page builds
    Get.put<QuizController>(QuizController(), permanent: false);
  }
}
