import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_get_medicine_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffGetMedicineConntroller extends GetxController {
  var staffgetmedicineDataResponce = StaffGetMedicinedata().obs;
  final StaffModuleService staffmoduleService;

  StaffGetMedicineConntroller(this.staffmoduleService);

  void fetchgetmedicinedata() async {
    try {
      staffgetmedicineDataResponce.value = await staffmoduleService.fetchgetmedicinedata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchgetmedicinedata(); // Fetch data on controller initialization
    super.onInit();
  }
}