import 'package:get/get.dart';
import 'package:superapp/model/over_view/get_feed_model.dart';
import 'package:superapp/services/overview_Service.dart';

class GetFeedController extends GetxController {
  var getfeedDataResponce = Getfeedata().obs;
  final OverviewService overviewService;

  GetFeedController(this.overviewService);

  void fetchgetfeedata({
    required String tankId,
    required String farmId,
    required String speciesId,
  }) async {
    try {
      getfeedDataResponce.value = await overviewService.fetchgetfeedata(
        tankId: tankId,
        farmId: farmId,
        speciesId: speciesId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("getFeedController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchgetfeedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
