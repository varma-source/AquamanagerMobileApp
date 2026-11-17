import 'package:get/get.dart';
import 'package:superapp/model/over_view/home_feeding_fcr_model.dart';
import 'package:superapp/services/overview_Service.dart';

class HomeFeedingFcrController extends GetxController {
  var homefeedfcrDataResponce = Feedingandfcrdata().obs;
  final OverviewService overviewService;

  HomeFeedingFcrController(this.overviewService);

  void fetchfeedingfcrdata({
    required String speciesId,
    required String tankId,
    required String purchaseId,
    required String farmId,
  }) async {
    try {
      homefeedfcrDataResponce.value = await overviewService.fetchfeedingfcrdata(
        speciesId: speciesId,
        tankId: tankId,
        purchaseId: purchaseId,
        farmId: farmId
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("homeFeedingFcrController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchfeedingfcrdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
