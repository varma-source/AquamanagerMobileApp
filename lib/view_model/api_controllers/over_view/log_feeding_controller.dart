import 'package:get/get.dart';
import 'package:superapp/model/over_view/log_feeding_model.dart';
import 'package:superapp/services/overview_Service.dart';

class LogFeedingController extends GetxController {
  var logfeedDataResponce = Logfeedingdata().obs;
  final OverviewService overviewService;

  LogFeedingController(this.overviewService);

  void fetchlogfeedata({
    required String tankId,
    required String farmId,
    required String speciesId,
  }) async {
    try {
      logfeedDataResponce.value = await overviewService.fetchlogfeedata(
        tankId: tankId,
        farmId: farmId,
        speciesId: speciesId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("logFeedingController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchlogfeedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
