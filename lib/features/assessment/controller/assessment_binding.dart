import 'package:get/get.dart';
import '../controller/assessment_controller.dart';

/// Binding for Skill Assessment feature dependencies
class AssessmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentController>(() => AssessmentController());
  }
}
