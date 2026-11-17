import 'package:get/get.dart';
import 'package:superapp/model/over_view/party_model.dart';
import 'package:superapp/services/overview_Service.dart';

class PartyController extends GetxController {
  var partyDataResponce = Partysdropdata().obs;
  final OverviewService overviewService;

  PartyController(this.overviewService);

  void fetchpartydata() async {
    try {
      partyDataResponce.value = await overviewService.fetchpartydata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("partyController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchpartydata(); // Fetch data on controller initialization
    super.onInit();
  }
}