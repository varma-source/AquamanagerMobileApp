import 'package:get/get.dart';
import 'package:superapp/model/over_view/biomass_model.dart';
import 'package:superapp/services/overview_Service.dart';

class BiomassController extends GetxController {
  var biomassDataResponce = Biomassdata().obs;
  final OverviewService overviewService;

  BiomassController(this.overviewService);

  void fetchbiomassdata({
    required String farmId,
    required String tankId,
  }) async {
    try {
      biomassDataResponce.value = await overviewService.fetchbiomassdata(
        farmId: farmId,
        tankId: tankId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("biomassController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchbiomassdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
