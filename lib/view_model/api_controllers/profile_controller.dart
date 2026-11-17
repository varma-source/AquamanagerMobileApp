import 'package:get/get.dart';
import 'package:superapp/model/profile_model.dart';
import 'package:superapp/services/profileService.dart';

class ProfileController extends GetxController {
  var profileDataResponce = Profiledata().obs;
  final ProfileService profileService;

  ProfileController(this.profileService);

  void fetchgetprofiledata() async {
    try {
      profileDataResponce.value = await profileService.fetchgetprofiledata();
      // print(plansApiResponse.value);
    } catch (e) {
      print("fdfjdkfkdfdfdfdkdkfj$e");
      // Handle error
    }
  }

  @override
  void onInit() {
    fetchgetprofiledata(); // Fetch data on controller initialization
    super.onInit();
  }
}