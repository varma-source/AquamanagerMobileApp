import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_profile_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffProfileController extends GetxController {
  var staffprofileDataResponce = StaffProfiledata().obs;
  final StaffModuleService staffmoduleService;

  StaffProfileController(this.staffmoduleService);

  void fetchstaffprofiledata() async {
    try {
      staffprofileDataResponce.value = await staffmoduleService.fetchstaffprofiledata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffprofiledata(); // Fetch data on controller initialization
    super.onInit();
  }
}