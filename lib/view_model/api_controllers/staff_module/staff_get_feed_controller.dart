import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_get_feed_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffGetFeedController extends GetxController {
  var staffgetfeedDataResponce = StaffGetFeedetails().obs;
  final StaffModuleService staffmoduleService;

  StaffGetFeedController(this.staffmoduleService);

  void fetchstaffgetfeedata({
    required String tankId,
    required String farmId,
    required String speciesId,
  }) async {
    try {
      staffgetfeedDataResponce.value = await staffmoduleService
          .fetchstaffgetfeedata(
            tankId: tankId,
            farmId: farmId,
            speciesId: speciesId,
          );
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchstaffgetfeedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
