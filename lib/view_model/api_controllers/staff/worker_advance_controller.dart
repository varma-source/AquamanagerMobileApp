import 'package:get/get.dart';
import 'package:superapp/model/staff/worker_advance_model.dart';
import 'package:superapp/services/tankService.dart';

class WorkerAdvanceController extends GetxController {
  var workeradvanceDataResponce = Workeradvancedata().obs;
  final TankService tankService;

  WorkerAdvanceController(this.tankService);

  void fetchworkeradvancedata({required String workerId}) async {
    try {
      workeradvanceDataResponce.value = await tankService.fetchworkeradvancedata(workerId: workerId);
      // print(plansApiResponse.value);
    } catch (e) {
      print("workerAdvanceController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    // fetchworkeradvancedata(); // Fetch data on controller initialization
    super.onInit();
  }
}