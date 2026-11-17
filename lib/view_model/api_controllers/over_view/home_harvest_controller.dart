import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_harvest_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HomeHarvestController extends GetxController {
  var homeharvestDataResponce = Homeharvestdata().obs;
  final OverviewService overviewService;

  HomeHarvestController(this.overviewService);

  void fetchomeharverstdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      homeharvestDataResponce.value = await overviewService
          .fetchomeharverstdata(tankId: tankId, farmId: farmId);
    } catch (e) {
      print("homeHarvestController$e");
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
