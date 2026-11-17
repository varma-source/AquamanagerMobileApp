import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_home_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffHomeController extends GetxController {
  var staffprofileDataResponce = StaffHomedata().obs;
  final StaffModuleService staffmoduleService;

  StaffHomeController(this.staffmoduleService);

  void fetchstaffhomedata() async {
    try {
      staffprofileDataResponce.value = await staffmoduleService.fetchstaffhomedata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffhomedata(); // Fetch data on controller initialization
    super.onInit();
  }
}