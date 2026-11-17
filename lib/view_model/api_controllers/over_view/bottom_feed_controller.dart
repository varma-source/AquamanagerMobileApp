import 'package:get/get.dart';
import 'package:superapp/model/over_view/bottom_feed_model.dart';
import 'package:superapp/services/overview_Service.dart';

class BottomFeedController extends GetxController {
  var bottomfeedDataResponce = Bottomfeeddata().obs;
  final OverviewService overviewService;

  BottomFeedController(this.overviewService);

  void fetchbottomfeedata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      bottomfeedDataResponce.value = await overviewService.fetchbottomfeedata(
        tankId: tankId,
        fromDate: fromDate,
        toDate: toDate,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("bottomFeedController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchbottomfeedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
