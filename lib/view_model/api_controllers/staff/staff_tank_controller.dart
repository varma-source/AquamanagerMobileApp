import 'package:get/get.dart';
import 'package:superapp/model/staff/staff_tank_model.dart';
import 'package:superapp/services/tankService.dart';

class StaffTankController extends GetxController {
  var stafftankDataResponce = Stafftankdata().obs;
  final TankService tankService;

  StaffTankController(this.tankService);

  void fetchstafftankdata() async {
    try {
      stafftankDataResponce.value = await tankService.fetchstafftankdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("staffTankController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstafftankdata(); // Fetch data on controller initialization
    super.onInit();
  }
}