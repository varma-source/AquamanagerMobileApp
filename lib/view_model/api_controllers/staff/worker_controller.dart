import 'package:get/get.dart';
import 'package:superapp/model/staff/worker_model.dart';
import 'package:superapp/services/tankService.dart';

class WorkerController extends GetxController {
  var workerDataResponce = Workersdata().obs;
  final TankService tankService;

  WorkerController(this.tankService);

  void fetchworkerdata() async {
    try {
      workerDataResponce.value = await tankService.fetchworkerdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("workerController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchworkerdata(); // Fetch data on controller initialization
    super.onInit();
  }
}