import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_crop_drop_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffCropDropController extends GetxController {
  var staffcropdropDataResponce = StaffCropDropdata().obs;
  final StaffModuleService staffmoduleService;

  StaffCropDropController(this.staffmoduleService);

  void fetchstaffcropdropdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      staffcropdropDataResponce.value = await staffmoduleService
          .fetchstaffcropdropdata(tankId: tankId, farmId: farmId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchstaffcropdropdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
