import 'package:get/get.dart';
import 'package:superapp/model/tank/tank_staff_model.dart';
import 'package:superapp/services/tankService.dart';

class TankStaffController extends GetxController {
  var tankstaffDataResponce = TankStaffData().obs;
  final TankService tankService;

  TankStaffController(this.tankService);

  void fetchtankstaffdata() async {
    try {
      tankstaffDataResponce.value = await tankService.fetchtankstaffdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("TankStaffController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchtankstaffdata(); // Fetch data on controller initialization
    super.onInit();
  }
}