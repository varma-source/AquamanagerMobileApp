import 'package:get/get.dart';
import 'package:superapp/model/over_view/expense_party_model.dart';
import 'package:superapp/services/overview_Service.dart';

class ExpensePartyController extends GetxController {
  var expenseDataResponce = ExpensePartyData().obs;
  final OverviewService overviewService;

  ExpensePartyController(this.overviewService);

  void fetchexpensepartydata() async {
    try {
      expenseDataResponce.value = await overviewService.fetchexpensepartydata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("ExpensePartyController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchexpensepartydata(); // Fetch data on controller initialization
    super.onInit();
  }
}