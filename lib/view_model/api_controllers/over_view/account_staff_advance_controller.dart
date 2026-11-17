import 'package:get/get.dart';
import 'package:superapp/model/over_view/account_staff_advance_model.dart';
import 'package:superapp/services/overview_Service.dart';

class AccountStaffAdvanceController extends GetxController {
  var accountstaffadvanceDataResponce = AccountStaffAdvancesdata().obs;
  final OverviewService overviewService;

  AccountStaffAdvanceController(this.overviewService);

  void fetchgetaccountadvancedata() async {
    try {
      accountstaffadvanceDataResponce.value = await overviewService.fetchgetaccountadvancedata(
      );
      // print(plansApiResponse.value);
    } catch (e) {
      print("AccountStaffAdvanceController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchgetaccountadvancedata(); // Fetch data on controller initialization
    super.onInit();
  }
}
