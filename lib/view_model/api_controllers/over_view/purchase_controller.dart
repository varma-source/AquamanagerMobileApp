import 'package:get/get.dart';
import 'package:superapp/model/over_view/purchase_model.dart';
import 'package:superapp/services/overview_Service.dart';

class PurchaseController extends GetxController {
  var purchaseDataResponce = Purchasedata().obs;
  final OverviewService overviewService;

  PurchaseController(this.overviewService);

  void fetchpurchasedata({
    required String tankId,
    required String farmId,
  }) async {
    try {
      purchaseDataResponce.value = await overviewService.fetchpurchasedata(
        tankId: tankId,
        farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("purchaseController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchpurchasedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
