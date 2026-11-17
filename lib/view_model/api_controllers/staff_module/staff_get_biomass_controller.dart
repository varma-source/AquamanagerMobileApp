import 'package:get/get.dart';
import 'package:superapp/model/staff_module/staff_get_biomass_model.dart';
import 'package:superapp/services/staff_module_service.dart';

class StaffGetBiomassController extends GetxController {
  var staffgetbiomassDataResponce = StaffGetBiomassetails().obs;
  final StaffModuleService staffmoduleService;

  StaffGetBiomassController(this.staffmoduleService);

  void fetchstaffgetbiomassdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      staffgetbiomassDataResponce.value = await staffmoduleService
          .fetchstaffgetbiomassdata(
            tankId: tankId,
            farmId: farmId,
          );
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchstaffgetbiomassdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
