import 'package:get/get.dart';
import 'package:superapp/model/over_view/feed_party_model.dart';
import 'package:superapp/services/overview_Service.dart';

class FeedPartyController extends GetxController {
  var feedpartyDataResponce = FeedPartyData().obs;
  final OverviewService overviewService;

  FeedPartyController(this.overviewService);

  void fetchfeddpartydata() async {
    try {
      feedpartyDataResponce.value = await overviewService.fetchfeddpartydata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("FeedPartyController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchfeddpartydata(); // Fetch data on controller initialization
    super.onInit();
  }
}