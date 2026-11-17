import 'package:get/get.dart';
import 'package:superapp/model/over_view/medicine_data_model.dart';
import 'package:superapp/services/overview_Service.dart';

class MedicineController extends GetxController {
  var medicineDataResponce = Medicinedata().obs;
  final OverviewService overviewService;

  MedicineController(this.overviewService);

  void fetchmedicinedata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      medicineDataResponce.value = await overviewService.fetchmedicinedata(
        tankId: tankId,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("medicineController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchmedicinedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
