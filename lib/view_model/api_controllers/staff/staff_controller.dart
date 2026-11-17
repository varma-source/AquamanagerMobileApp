import 'package:get/get.dart';
import 'package:superapp/model/staff/staff_model.dart';
import 'package:superapp/services/tankService.dart';

class StaffController extends GetxController {
  var staffDataResponce = Staffdata().obs;
  final TankService tankService;

  StaffController(this.tankService);

  void fetchstaffdata() async {
    try {
      staffDataResponce.value = await tankService.fetchstaffdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("staffController$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchstaffdata(); // Fetch data on controller initialization
    super.onInit();
  }
}