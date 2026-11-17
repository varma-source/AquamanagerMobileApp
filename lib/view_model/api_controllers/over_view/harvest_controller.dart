import 'package:get/get.dart';
import 'package:superapp/model/over_view/harvest_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HarvestController extends GetxController {
  var harvestDataResponce = Harvestdata().obs;
  final OverviewService overviewService;

  HarvestController(this.overviewService);

  void fetchharvestdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      harvestDataResponce.value = await overviewService.fetchharvestdata(
        tankId: tankId,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("harvestController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchharvestdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
