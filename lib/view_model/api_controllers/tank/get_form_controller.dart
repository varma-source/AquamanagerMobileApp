import 'package:get/get.dart';
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/services/tankService.dart';

class GetFormController extends GetxController {
  var getformDataResponce = Getformdata().obs;
  final TankService tankService;

  GetFormController(this.tankService);

  void fetchgetformdata() async {
    try {
      getformDataResponce.value = await tankService.fetchgetformdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchgetformdata(); // Fetch data on controller initialization
    super.onInit();
  }
}