import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_medicine_mosel.dart';
import 'package:superapp/services/overview_Service.dart';

class HomeMedicineController extends GetxController {
  var homemediDataResponce = Homemedicinedata().obs;
  final OverviewService overviewService;

  HomeMedicineController(this.overviewService);

  void fetchhomemedicinedata({
    required String tankId,
    required String medicineId,
    required String medicineType,
    required String farmId,
  }) async {
    try {
      homemediDataResponce.value = await overviewService.fetchhomemedicinedata(
        tankId: tankId,
        medicineId: medicineId,
        medicineType: medicineType, farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("homeMedicineController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchhomemedicinedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
