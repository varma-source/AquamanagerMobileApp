import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/services/tankService.dart';

class GetAllTankConteoller extends GetxController {
  // ✅ Observable response
  var tanksDataResponce = AllTankdata().obs;
  
  final TankService tankService;

  GetAllTankConteoller(this.tankService);

  Future<void> fetchgetanksdata({required String farmId}) async {
    try {
      debugPrint("🔄 Fetching tanks for farmId: $farmId");
      
      // ✅ Fetch data using the TankService
      final result = await tankService.fetchgetanksdata(farmId: farmId);
      
      // ✅ Update the observable state
      tanksDataResponce.value = result;
      
      debugPrint("✅ Got ${result.tanks?.length ?? 0} tanks");
    } catch (e) {
      debugPrint("❌ fetchgetanksdata error: $e");
      
      // ✅ Safely reset to empty so UI doesn't show stale data or crash
      tanksDataResponce.value = AllTankdata(
        success: false,
        message: e.toString(),
        tanks: [],
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}