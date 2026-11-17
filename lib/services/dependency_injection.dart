import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/services/authService.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/services/user_Service.dart';
import 'package:superapp/view_model/api_controllers/api_logics/token_controller.dart';
import 'package:superapp/view_model/api_controllers/notification_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_balance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_get_expense_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_staff_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/expence_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/expense_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/feed_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/get_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/harvest_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_feeding_fcr_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_feeding_stock_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_harvest_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/log_feeding_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/purchase_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/species_controller.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/get_worker_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_tank_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_crop_drop_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_expence_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_feed_drop_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_medicine_conntroller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_home_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_manager_staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_medicine_drop_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_my_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_profile_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_request_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/tank_staff_controller.dart';
import 'package:superapp/view_model/api_controllers/ui_controllers/bottomNavigation_controller.dart';
import 'package:superapp/view_model/api_controllers/ui_controllers/timer_controller.dart';

class DependencyInjection {
  static void init() async {
    // ✅ Initialize NetworkController first
    Get.put<NetworkController>(NetworkController(), permanent: true);

    // ✅ Initialize UI controllers
    Get.put(TimerController(), permanent: true);
    Get.put(BottomNavigationController(), permanent: true);
    Get.put(TokenController(), permanent: true);

    // ✅ Initialize Services
    Get.put(Authservice(), permanent: true);
    // Get.put(UserService(), permanent: true);
    Get.put(ProfileService(), permanent: true);
    Get.put(TankService(), permanent: true);
    Get.put(OverviewService(), permanent: true);
    Get.put(StaffModuleService(), permanent: true);

    // ✅ LAZILY initialize ALL controllers that might be needed before login
    // These will only be created when first accessed
    Get.lazyPut(() => ProfileController(Get.find<ProfileService>()), fenix: true);
    Get.lazyPut(() => GetAllTankConteoller(Get.find<TankService>()), fenix: true);
    Get.lazyPut(() => StaffController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => WorkerController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => WorkerAdvanceController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => PartyController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => GetFeedController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => MedicineController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => SpeciesController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomeTankOverViewController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => PurchaseController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomeFeedingFcrController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => BiomassController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => LogFeedingController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomeFeedingStockController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomeMedicineController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => MedicineUseageController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HarvestController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomeHarvestController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => ExpenceController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => HomePandlController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => PartyAdvanceController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => BottomPandlController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => AccountBalanceController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => BottomFeedController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => BottomMedicineController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => GetWorkerController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => GetFormController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => StaffTankController(Get.find<TankService>()),fenix: true);
    Get.lazyPut(() => StaffProfileController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffHomeController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffExpenceController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffMedicineDropController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffGetMedicineConntroller(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffCropDropController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffFeedDropController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffGetFeedController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffGetBiomassController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffMyFeedController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffRequestAdvanceController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => StaffManagerStaffController(Get.find<StaffModuleService>()),fenix: true);
    Get.lazyPut(() => AccountGetExpenseController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => NotificationController(Get.find<ProfileService>()),fenix: true);
    Get.lazyPut(() => MedicinePartyController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => AccountStaffAdvanceController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => FeedPartyController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => ExpensePartyController(Get.find<OverviewService>()),fenix: true);
    Get.lazyPut(() => TankStaffController(Get.find<TankService>()),fenix: true);

    // ✅ Check for existing token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _token = await prefs.getString('accessToken') ?? "";

    await AppTokens().setAccessToken(_token);

    if (_token != "") {
      // If token exists, fetch initial data for controllers
      await _initializeControllersWithToken();
    }
  }

  static Future<void> _initializeControllersWithToken() async {
    // This method can be used to fetch initial data if needed
    // For example, you might want to fetch user profile immediately
    try {
      final profileController = Get.find<ProfileController>();
      // Uncomment if you want to fetch profile data immediately
      // await profileController.fetchProfileData();
    } catch (e) {
      print("Error initializing controllers with token: $e");
    }
  }

  static void resetControllers() {
    // Clear all controllers except permanent ones
    Get.delete<ProfileController>();
    Get.delete<GetAllTankConteoller>();
    Get.delete<StaffController>();
    Get.delete<WorkerController>();
    Get.delete<WorkerAdvanceController>();
    Get.delete<PartyController>();
    Get.delete<GetFeedController>();
    Get.delete<MedicineController>();
    Get.delete<SpeciesController>();
    Get.delete<HomeTankOverViewController>();
    Get.delete<PurchaseController>();
    Get.delete<HomeFeedingFcrController>();
    Get.delete<BiomassController>();
    Get.delete<LogFeedingController>();
    Get.delete<HomeFeedingStockController>();
    Get.delete<HomeMedicineController>();
    Get.delete<MedicineUseageController>();
    Get.delete<HarvestController>();
    Get.delete<HomeHarvestController>();
    Get.delete<ExpenceController>();
    Get.delete<HomePandlController>();
    Get.delete<PartyAdvanceController>();
    Get.delete<BottomPandlController>();
    Get.delete<AccountBalanceController>();
    Get.delete<BottomFeedController>();
    Get.delete<BottomMedicineController>();
    Get.delete<GetWorkerController>();
    Get.delete<GetFormController>();
    Get.delete<StaffTankController>();
    Get.delete<StaffProfileController>();
    Get.delete<StaffHomeController>();
    Get.delete<StaffExpenceController>();
    Get.delete<StaffMedicineDropController>();
    Get.delete<StaffGetMedicineConntroller>();
    Get.delete<StaffCropDropController>();
    Get.delete<StaffFeedDropController>();
    Get.delete<StaffGetFeedController>();
    Get.delete<StaffGetBiomassController>();
    Get.delete<StaffMyFeedController>();
    Get.delete<StaffRequestAdvanceController>();
    Get.delete<StaffManagerStaffController>();
    Get.delete<AccountGetExpenseController>();
    Get.delete<NotificationController>();
    Get.delete<MedicinePartyController>();
    Get.delete<AccountStaffAdvanceController>();
    Get.delete<FeedPartyController>();
    Get.delete<ExpensePartyController>();
    Get.delete<TankStaffController>();
  }

  // ✅ Helper method to ensure a controller is initialized
  static T ensureController<T>(T Function() creator) {
    if (!Get.isRegistered<T>()) {
      Get.put(creator());
    }
    return Get.find<T>();
  }

  static void apiInit() {}
}

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    print("NetworkController initialized");
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        Get.rawSnackbar(
          messageText: const Text(
            'PLEASE CONNECT TO THE INTERNET',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400]!,
          icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.FLOATING,
        );
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
          Get.rawSnackbar(
            messageText: const Text(
              'RECONNECTED TO THE INTERNET',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            isDismissible: true,
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green[400]!,
            icon: const Icon(Icons.wifi, color: Colors.white, size: 35),
            margin: EdgeInsets.zero,
            snackStyle: SnackStyle.FLOATING,
          );
        }
      }
    });
  }
}