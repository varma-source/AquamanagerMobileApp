import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_request_advance_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffRequestAdvanceController extends GetxController {
  var staffrequestadvanceDataResponce = StaffRequestAdvancedata().obs;
  final StaffModuleService staffmoduleService;

  StaffRequestAdvanceController(this.staffmoduleService);

  void fetchrequestadvancedata() async {
    try {
      staffrequestadvanceDataResponce.value = await staffmoduleService.fetchrequestadvancedata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchrequestadvancedata(); // Fetch data on controller initialization
    super.onInit();
  }
}