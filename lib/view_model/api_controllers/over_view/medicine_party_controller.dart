import 'package:get/get.dart';
import 'package:superapp/model/over_view/medicine_party_model.dart';
import 'package:superapp/services/overview_Service.dart';

class MedicinePartyController extends GetxController {
  var medicinepartyDataResponce = MedicinePartydata().obs;
  final OverviewService overviewService;

  MedicinePartyController(this.overviewService);

  void fetchmedicinepartydata() async {
    try {
      medicinepartyDataResponce.value = await overviewService.fetchmedicinepartydata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("MedicinePartyController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchmedicinepartydata(); // Fetch data on controller initialization
    super.onInit();
  }
}