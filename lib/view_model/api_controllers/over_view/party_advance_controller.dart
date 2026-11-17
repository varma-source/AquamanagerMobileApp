import 'package:get/get.dart';
import 'package:superapp/model/over_view/party_advance_model.dart';
import 'package:superapp/services/overview_Service.dart';

class PartyAdvanceController extends GetxController {
  var partyadvDataResponce = Partyadvancedata().obs;
  final OverviewService overviewService;

  PartyAdvanceController(this.overviewService);

  void fetchpartyadvance({required String partyId}) async {
    try {
      partyadvDataResponce.value = await overviewService.fetchpartyadvance(
        partyId: partyId,
      );
    } catch (e) {
      print("partyAdvanceController $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}