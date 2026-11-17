import 'package:get/get.dart';
import 'package:superapp/model/over_view/bottom_madicine_model.dart';
import 'package:superapp/services/overview_Service.dart';

class BottomMedicineController extends GetxController {
  var bottommedicineDataResponce = Bottommedicinedata().obs;
  final OverviewService overviewService;

  BottomMedicineController(this.overviewService);

  void fetchbottomedicinedata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      bottommedicineDataResponce.value = await overviewService
          .fetchbottomedicinedata(
            tankId: tankId,
            fromDate: fromDate,
            toDate: toDate,
            farmId: farmId,
          );
      // print(plansApiResponse.value);
    } catch (e) {
      print("bottomMedicineController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchbottomedicinedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
