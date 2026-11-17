import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_feeding_stock_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HomeFeedingStockController extends GetxController {
  var feedingstockDataResponce = Feedingstockdata().obs;
  final OverviewService overviewService;

  HomeFeedingStockController(this.overviewService);

  void fetchfeedstockdata({
    required String tankId,
    required String purchaseId,
    required String farmId
  }) async {
    try {
      feedingstockDataResponce.value = await overviewService.fetchfeedstockdata(
        tankId: tankId,
        purchaseId: purchaseId, farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("homeFeedingStockController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchfeedstockdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
