import 'package:get/get.dart';
import '../controller/assessment_controller.dart';

/// Binding for Skill Assessment feature dependencies
class AssessmentBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut with fenix: true to keep controller alive across navigation
    // Check if already registered to prevent duplicates
    if (!Get.isRegistered<AssessmentController>()) {
      Get.lazyPut<AssessmentController>(
        () => AssessmentController(),
        fenix: true,
      );
    }
  }
}
