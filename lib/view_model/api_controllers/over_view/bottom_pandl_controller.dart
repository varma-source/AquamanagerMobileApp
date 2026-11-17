import 'package:get/get.dart';
import 'package:superapp/model/over_view/bottom_pandl_model.dart';
import 'package:superapp/services/overview_Service.dart';

class BottomPandlController extends GetxController {
  var bottomplDataResponce = Bottompandldata().obs;
  final OverviewService overviewService;

  BottomPandlController(this.overviewService);

  // ✅ Returns Future<void> so callers can await it
  Future<void> fetchbottompandl({
    required String toDate,
    required String fromDate,
    required String tankId,
    required String farmId,
  }) async {
    try {
      bottomplDataResponce.value = await overviewService.fetchbottompandl(
        tankId: tankId,
        fromDate: fromDate,
        toDate: toDate,
        farmId: farmId,
      );
    } catch (e) {
      print("BottomPandl fetch error: $e");
      rethrow; // let caller know it failed (optional)
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
