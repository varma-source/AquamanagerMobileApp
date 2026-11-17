import 'package:get/get.dart';
import 'package:superapp/model/over_view/account_balance_model.dart';
import 'package:superapp/services/overview_Service.dart';

class AccountBalanceController extends GetxController {
  var accountbalDataResponce = Accountbalancedata().obs;
  final OverviewService overviewService;

  AccountBalanceController(this.overviewService);

  void fetchaccountdata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      accountbalDataResponce.value = await overviewService.fetchaccountdata(
        tankId: tankId,
        fromDate: fromDate,
        toDate: toDate, farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("accountBalanceController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchaccountdata(); // Fetch data on controller initialization
    super.onInit();
  }
}
