import 'package:get/get.dart';
import 'package:superapp/model/staff/get_worker_model.dart';
import 'package:superapp/services/tankService.dart';

class GetWorkerController extends GetxController {
  var getworkerDataResponce = Getworkerdata().obs;
  final TankService tankService;

  GetWorkerController(this.tankService);

  void fetchgetworkerdata() async {
    try {
      getworkerDataResponce.value = await tankService.fetchgetworkerdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("getWorkerController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchgetworkerdata(); // Fetch data on controller initialization
    super.onInit();
  }
}