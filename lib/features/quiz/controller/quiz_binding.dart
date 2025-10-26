import 'package:get/get.dart';
import '../controller/quiz_controller.dart';

/// Dependency injection for QuizController
class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizController>(() => QuizController());
  }
}
