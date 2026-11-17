import 'package:get/get.dart';
import 'package:superapp/model/over_view/medicine_useage_model.dart';
import 'package:superapp/services/overview_Service.dart';

class MedicineUseageController extends GetxController {
  var medicineuseDataResponce = Medicineuseagedata().obs;
  final OverviewService overviewService;

  MedicineUseageController(this.overviewService);

  void fetchmedicineuseagedata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      medicineuseDataResponce.value = await overviewService
          .fetchmedicineuseagedata(tankId: tankId, farmId: farmId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("medicineUseageController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchmedicineuseagedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
