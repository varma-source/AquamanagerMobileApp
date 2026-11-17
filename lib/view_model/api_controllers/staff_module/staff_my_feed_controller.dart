import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_my_feed_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffMyFeedController extends GetxController {
  var staffmyfeedDataResponce = StaffMyFeeddata().obs;
  final StaffModuleService staffmoduleService;

  StaffMyFeedController(this.staffmoduleService);

  void fetchstaffmyfeedata() async {
    try {
      staffmyfeedDataResponce.value = await staffmoduleService.fetchstaffmyfeedata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffmyfeedata(); // Fetch data on controller initialization
    super.onInit();
  }
}