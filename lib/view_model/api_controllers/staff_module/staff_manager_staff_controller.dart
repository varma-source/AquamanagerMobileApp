import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_manager_staff_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffManagerStaffController extends GetxController {
  var staffmanagerstaffDataResponce = StaffManagerStaffdata().obs;
  final StaffModuleService staffmoduleService;

  StaffManagerStaffController(this.staffmoduleService);

  void fetchstaffmanagerstaffdata() async {
    try {
      staffmanagerstaffDataResponce.value =
          await staffmoduleService.fetchstaffmanagerstaffdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffmanagerstaffdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
