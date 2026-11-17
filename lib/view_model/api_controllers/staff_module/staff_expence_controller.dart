import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_expense_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffExpenceController extends GetxController {
  var staffexpenceDataResponce = Staffexpensedata().obs;
  final StaffModuleService staffmoduleService;

  StaffExpenceController(this.staffmoduleService);

  void fetchstaffexpensedata() async {
    try {
      staffexpenceDataResponce.value = await staffmoduleService.fetchstaffexpensedata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffexpensedata(); // Fetch data on controller initialization
    super.onInit();
  }
}