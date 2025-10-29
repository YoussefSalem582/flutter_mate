import 'package:get/get.dart';
import '../controller/analytics_controller.dart';

/// Binding for Analytics feature dependencies
class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
