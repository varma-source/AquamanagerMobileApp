import 'package:get/get.dart';
import 'package:superapp/model/over_view/expence_model.dart';
import 'package:superapp/services/overview_Service.dart';

class ExpenceController extends GetxController {
  var expenceDataResponce = Expencedata().obs;
  final OverviewService overviewService;

  ExpenceController(this.overviewService);

  void fetchexpencedata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      expenceDataResponce.value = await overviewService.fetchexpencedata(
        tankId: tankId,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("expenceController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchexpencedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
