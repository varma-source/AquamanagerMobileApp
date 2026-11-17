import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_medicine_drop_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffMedicineDropController extends GetxController {
  var staffmedicinedrDataResponce = StaffMedicineDropdata().obs;
  final StaffModuleService staffmoduleService;

  StaffMedicineDropController(this.staffmoduleService);

  void fetchstaffmedicinedropdata({
    required String farmId,
    required String tankId,
  }) async {
    try {
      staffmedicinedrDataResponce.value =
          await staffmoduleService.fetchstaffmedicinedropdata(farmId: farmId, tankId: tankId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchstaffmedicinedropdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
