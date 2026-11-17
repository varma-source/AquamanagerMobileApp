import 'package:get/get.dart';
import 'package:superapp/model/notification_model.dart';
import 'package:superapp/services/profileService.dart';

class NotificationController extends GetxController {
  var notificationDataResponce = Notificationsdata().obs;
  final ProfileService profileService;

  NotificationController(this.profileService);

  void fetchnotificationsdata() async {
    try {
      notificationDataResponce.value = await profileService.fetchnotificationsdata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchnotificationsdata(); // Fetch data on controller initialization
    super.onInit();
  }
}