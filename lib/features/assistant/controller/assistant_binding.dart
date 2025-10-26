import 'package:get/get.dart';
import 'assistant_controller.dart';

class AssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssistantController>(() => AssistantController());
  }
}
