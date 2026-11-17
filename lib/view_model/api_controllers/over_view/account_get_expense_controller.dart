import 'package:get/get.dart';
import 'package:superapp/model/over_view/account_get_expence_model.dart';
import 'package:superapp/services/overview_Service.dart';

class AccountGetExpenseController extends GetxController {
  var accountgetexpenseDataResponce = AccountGetExpensedata().obs;
  final OverviewService overviewService;

  AccountGetExpenseController(this.overviewService);

  void fetchaccountgetexpencedata({
    required String farmId,
    required String tankId,
  }) async {
    try {
      accountgetexpenseDataResponce.value = await overviewService.fetchaccountgetexpencedata(
        tankId: tankId, farmId: farmId,
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("accountGetExpenseController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchaccountgetexpencedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
