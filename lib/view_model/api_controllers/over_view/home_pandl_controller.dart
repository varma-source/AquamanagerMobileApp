import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_pandl_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HomePandlController extends GetxController {
  var homepandlDataResponce = HomePandLdata().obs;
  final OverviewService overviewService;

  HomePandlController(this.overviewService);

  void fetchgetpandldata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      homepandlDataResponce.value = await overviewService.fetchgetpandldata(
        tankId: tankId,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("homePandlController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchgetpandldata(); // Fetch data on controller initialization
    super.onInit();
  }
}
