import 'package:get/get.dart';
import '../controller/code_playground_controller.dart';
import '../data/repositories/code_playground_repository.dart';

class CodePlaygroundBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CodePlaygroundRepository>(() => CodePlaygroundRepositoryImpl());
    Get.lazyPut<CodePlaygroundController>(
      () => CodePlaygroundController(Get.find()),
    );
  }
}
