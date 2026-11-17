import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_feed_drop_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffFeedDropController extends GetxController {
  var stafffeeddropDataResponce = StaffFeedDropdata().obs;
  final StaffModuleService staffmoduleService;

  StaffFeedDropController(this.staffmoduleService);

  void fetchstafffeeddropdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      stafffeeddropDataResponce.value = await staffmoduleService
          .fetchstafffeeddropdata(tankId: tankId, farmId: farmId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchstafffeeddropdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
