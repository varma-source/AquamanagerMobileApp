import 'package:get/get.dart';

// ── Services ──
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/services/tankService.dart';

// ── Controllers ──
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';

import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/get_worker_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_tank_controller.dart';

import 'package:superapp/view_model/api_controllers/over_view/account_balance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/expence_controller.dart';
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
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/purchase_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/species_controller.dart';

class ControllerUtils {
  // ═══════════════════════════════════════════════════════════
  // SERVICES (kept for reference — erase + recreate on demand)
  // ═══════════════════════════════════════════════════════════
  static void _ensureServices() {
    if (!Get.isRegistered<ProfileService>()) {
      Get.put(ProfileService(), permanent: true);
    }
    if (!Get.isRegistered<TankService>()) {
      Get.put(TankService(), permanent: true);
    }
    if (!Get.isRegistered<OverviewService>()) {
      Get.put(OverviewService(), permanent: true);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════
  static ProfileController getProfileController() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(Get.find<ProfileService>()));
    }
    return Get.find<ProfileController>();
  }

  // ═══════════════════════════════════════════════════════════
  // TANK
  // ═══════════════════════════════════════════════════════════
  static GetAllTankConteoller getTankController() {
    if (!Get.isRegistered<GetAllTankConteoller>()) {
      Get.put(GetAllTankConteoller(Get.find<TankService>()));
    }
    return Get.find<GetAllTankConteoller>();
  }

  static GetFormController getFormController() {
    if (!Get.isRegistered<GetFormController>()) {
      Get.put(GetFormController(Get.find<TankService>()));
    }
    return Get.find<GetFormController>();
  }

  // ═══════════════════════════════════════════════════════════
  // STAFF
  // ═══════════════════════════════════════════════════════════
  static StaffController getStaffController() {
    if (!Get.isRegistered<StaffController>()) {
      Get.put(StaffController(Get.find<TankService>()));
    }
    return Get.find<StaffController>();
  }

  static WorkerController getWorkerController() {
    if (!Get.isRegistered<WorkerController>()) {
      Get.put(WorkerController(Get.find<TankService>()));
    }
    return Get.find<WorkerController>();
  }

  static WorkerAdvanceController getWorkerAdvanceController() {
    if (!Get.isRegistered<WorkerAdvanceController>()) {
      Get.put(WorkerAdvanceController(Get.find<TankService>()));
    }
    return Get.find<WorkerAdvanceController>();
  }

  static GetWorkerController getGetWorkerController() {
    if (!Get.isRegistered<GetWorkerController>()) {
      Get.put(GetWorkerController(Get.find<TankService>()));
    }
    return Get.find<GetWorkerController>();
  }

  static StaffTankController getStaffTankController() {
    if (!Get.isRegistered<StaffTankController>()) {
      Get.put(StaffTankController(Get.find<TankService>()));
    }
    return Get.find<StaffTankController>();
  }

  // ═══════════════════════════════════════════════════════════
  // OVERVIEW
  // ═══════════════════════════════════════════════════════════
  static HomeTankOverViewController getHomeTankOverviewController() {
    if (!Get.isRegistered<HomeTankOverViewController>()) {
      Get.put(HomeTankOverViewController(Get.find<OverviewService>()));
    }
    return Get.find<HomeTankOverViewController>();
  }

  static SpeciesController getSpeciesController() {
    if (!Get.isRegistered<SpeciesController>()) {
      Get.put(SpeciesController(Get.find<OverviewService>()));
    }
    return Get.find<SpeciesController>();
  }

  static PurchaseController getPurchaseController() {
    if (!Get.isRegistered<PurchaseController>()) {
      Get.put(PurchaseController(Get.find<OverviewService>()));
    }
    return Get.find<PurchaseController>();
  }

  static LogFeedingController getLogFeedingController() {
    if (!Get.isRegistered<LogFeedingController>()) {
      Get.put(LogFeedingController(Get.find<OverviewService>()));
    }
    return Get.find<LogFeedingController>();
  }

  static HomeFeedingFcrController getHomeFeedingFcrController() {
    if (!Get.isRegistered<HomeFeedingFcrController>()) {
      Get.put(HomeFeedingFcrController(Get.find<OverviewService>()));
    }
    return Get.find<HomeFeedingFcrController>();
  }

  static HomeFeedingStockController getHomeFeedingStockController() {
    if (!Get.isRegistered<HomeFeedingStockController>()) {
      Get.put(HomeFeedingStockController(Get.find<OverviewService>()));
    }
    return Get.find<HomeFeedingStockController>();
  }

  static BiomassController getBiomassController() {
    if (!Get.isRegistered<BiomassController>()) {
      Get.put(BiomassController(Get.find<OverviewService>()));
    }
    return Get.find<BiomassController>();
  }

  static MedicineController getMedicineController() {
    if (!Get.isRegistered<MedicineController>()) {
      Get.put(MedicineController(Get.find<OverviewService>()));
    }
    return Get.find<MedicineController>();
  }

  static HomeMedicineController getHomeMedicineController() {
    if (!Get.isRegistered<HomeMedicineController>()) {
      Get.put(HomeMedicineController(Get.find<OverviewService>()));
    }
    return Get.find<HomeMedicineController>();
  }

  static MedicineUseageController getMedicineUseageController() {
    if (!Get.isRegistered<MedicineUseageController>()) {
      Get.put(MedicineUseageController(Get.find<OverviewService>()));
    }
    return Get.find<MedicineUseageController>();
  }

  static HarvestController getHarvestController() {
    if (!Get.isRegistered<HarvestController>()) {
      Get.put(HarvestController(Get.find<OverviewService>()));
    }
    return Get.find<HarvestController>();
  }

  static HomeHarvestController getHomeHarvestController() {
    if (!Get.isRegistered<HomeHarvestController>()) {
      Get.put(HomeHarvestController(Get.find<OverviewService>()));
    }
    return Get.find<HomeHarvestController>();
  }

  static ExpenceController getExpenceController() {
    if (!Get.isRegistered<ExpenceController>()) {
      Get.put(ExpenceController(Get.find<OverviewService>()));
    }
    return Get.find<ExpenceController>();
  }

  static HomePandlController getHomePandlController() {
    if (!Get.isRegistered<HomePandlController>()) {
      Get.put(HomePandlController(Get.find<OverviewService>()));
    }
    return Get.find<HomePandlController>();
  }

  static BottomPandlController getBottomPandlController() {
    if (!Get.isRegistered<BottomPandlController>()) {
      Get.put(BottomPandlController(Get.find<OverviewService>()));
    }
    return Get.find<BottomPandlController>();
  }

  static AccountBalanceController getAccountBalanceController() {
    if (!Get.isRegistered<AccountBalanceController>()) {
      Get.put(AccountBalanceController(Get.find<OverviewService>()));
    }
    return Get.find<AccountBalanceController>();
  }

  static BottomFeedController getBottomFeedController() {
    if (!Get.isRegistered<BottomFeedController>()) {
      Get.put(BottomFeedController(Get.find<OverviewService>()));
    }
    return Get.find<BottomFeedController>();
  }

  static BottomMedicineController getBottomMedicineController() {
    if (!Get.isRegistered<BottomMedicineController>()) {
      Get.put(BottomMedicineController(Get.find<OverviewService>()));
    }
    return Get.find<BottomMedicineController>();
  }

  static PartyController getPartyController() {
    if (!Get.isRegistered<PartyController>()) {
      Get.put(PartyController(Get.find<OverviewService>()));
    }
    return Get.find<PartyController>();
  }

  static PartyAdvanceController getPartyAdvanceController() {
    if (!Get.isRegistered<PartyAdvanceController>()) {
      Get.put(PartyAdvanceController(Get.find<OverviewService>()));
    }
    return Get.find<PartyAdvanceController>();
  }

  static GetFeedController getGetFeedController() {
    if (!Get.isRegistered<GetFeedController>()) {
      Get.put(GetFeedController(Get.find<OverviewService>()));
    }
    return Get.find<GetFeedController>();
  }

  // ═══════════════════════════════════════════════════════════
  // INITIALIZE ALL  (erase first → recreate)
  // ═══════════════════════════════════════════════════════════
  /// Wipes every registered controller, ensures the required
  /// services exist, then re-creates all controllers fresh.
  /// Call this after a successful login/register.
  static void initializeAllControllers() {
    // 1️⃣ Erase everything first
    resetAllControllers();

    // 2️⃣ Make sure services are registered
    _ensureServices();

    // 3️⃣ Core
    getProfileController();
    getTankController();
    getFormController();

    // 4️⃣ Staff
    getStaffController();
    getWorkerController();
    getWorkerAdvanceController();
    getGetWorkerController();
    getStaffTankController();

    // 5️⃣ Overview
    getHomeTankOverviewController();
    getSpeciesController();
    getPurchaseController();
    getLogFeedingController();
    getHomeFeedingFcrController();
    getHomeFeedingStockController();
    getBiomassController();
    getMedicineController();
    getHomeMedicineController();
    getMedicineUseageController();
    getHarvestController();
    getHomeHarvestController();
    getExpenceController();
    getHomePandlController();
    getBottomPandlController();
    getAccountBalanceController();
    getBottomFeedController();
    getBottomMedicineController();
    getPartyController();
    getPartyAdvanceController();
    getGetFeedController();
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE ALL  (used on logout)
  // ═══════════════════════════════════════════════════════════
  static void resetAllControllers() {
    // Core
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
    if (Get.isRegistered<GetAllTankConteoller>()) {
      Get.delete<GetAllTankConteoller>(force: true);
    }
    if (Get.isRegistered<GetFormController>()) {
      Get.delete<GetFormController>(force: true);
    }

    // Staff
    if (Get.isRegistered<StaffController>()) {
      Get.delete<StaffController>(force: true);
    }
    if (Get.isRegistered<WorkerController>()) {
      Get.delete<WorkerController>(force: true);
    }
    if (Get.isRegistered<WorkerAdvanceController>()) {
      Get.delete<WorkerAdvanceController>(force: true);
    }
    if (Get.isRegistered<GetWorkerController>()) {
      Get.delete<GetWorkerController>(force: true);
    }
    if (Get.isRegistered<StaffTankController>()) {
      Get.delete<StaffTankController>(force: true);
    }

    // Overview
    if (Get.isRegistered<HomeTankOverViewController>()) {
      Get.delete<HomeTankOverViewController>(force: true);
    }
    if (Get.isRegistered<SpeciesController>()) {
      Get.delete<SpeciesController>(force: true);
    }
    if (Get.isRegistered<PurchaseController>()) {
      Get.delete<PurchaseController>(force: true);
    }
    if (Get.isRegistered<LogFeedingController>()) {
      Get.delete<LogFeedingController>(force: true);
    }
    if (Get.isRegistered<HomeFeedingFcrController>()) {
      Get.delete<HomeFeedingFcrController>(force: true);
    }
    if (Get.isRegistered<HomeFeedingStockController>()) {
      Get.delete<HomeFeedingStockController>(force: true);
    }
    if (Get.isRegistered<BiomassController>()) {
      Get.delete<BiomassController>(force: true);
    }
    if (Get.isRegistered<MedicineController>()) {
      Get.delete<MedicineController>(force: true);
    }
    if (Get.isRegistered<HomeMedicineController>()) {
      Get.delete<HomeMedicineController>(force: true);
    }
    if (Get.isRegistered<MedicineUseageController>()) {
      Get.delete<MedicineUseageController>(force: true);
    }
    if (Get.isRegistered<HarvestController>()) {
      Get.delete<HarvestController>(force: true);
    }
    if (Get.isRegistered<HomeHarvestController>()) {
      Get.delete<HomeHarvestController>(force: true);
    }
    if (Get.isRegistered<ExpenceController>()) {
      Get.delete<ExpenceController>(force: true);
    }
    if (Get.isRegistered<HomePandlController>()) {
      Get.delete<HomePandlController>(force: true);
    }
    if (Get.isRegistered<BottomPandlController>()) {
      Get.delete<BottomPandlController>(force: true);
    }
    if (Get.isRegistered<AccountBalanceController>()) {
      Get.delete<AccountBalanceController>(force: true);
    }
    if (Get.isRegistered<BottomFeedController>()) {
      Get.delete<BottomFeedController>(force: true);
    }
    if (Get.isRegistered<BottomMedicineController>()) {
      Get.delete<BottomMedicineController>(force: true);
    }
    if (Get.isRegistered<PartyController>()) {
      Get.delete<PartyController>(force: true);
    }
    if (Get.isRegistered<PartyAdvanceController>()) {
      Get.delete<PartyAdvanceController>(force: true);
    }
    if (Get.isRegistered<GetFeedController>()) {
      Get.delete<GetFeedController>(force: true);
    }
  }
}