import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HomeTankOverViewController extends GetxController {
  var hometankoverviewDataResponce = Hometankoverviewdata().obs;
  final OverviewService overviewService;

  HomeTankOverViewController(this.overviewService);

  void fetchhomeoverviewdata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      hometankoverviewDataResponce.value = await overviewService
          .fetchhomeoverviewdata(tankId: tankId, farmId: farmId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("homeTankOverViewController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchhomeoverviewdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
