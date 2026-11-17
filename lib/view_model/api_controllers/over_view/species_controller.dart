import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/model/over_view/species_model.dart';
import 'package:superapp/services/overview_Service.dart';

class SpeciesController extends GetxController {
  var speciesDataResponce = Speciesdata().obs;
  final OverviewService overviewService;

  SpeciesController(this.overviewService);

  Future<void> fetchspeciesdata({
    required String tankId,
    required String farmId,
  }) async {
    debugPrint("SpeciesController");

    try {
      final result = await overviewService.fetchspeciesdata(
        tankId: tankId,
        farmId: farmId,
      );

      speciesDataResponce.value = result;

      debugPrint(
          "✅ Species loaded: ${result.data?.length ?? 0} — names: ${result.data?.map((s) => s.speciesName).toList()}");
    } catch (e) {
      debugPrint("❌ fetchspeciesdata error: $e");

      speciesDataResponce.value = Speciesdata(
        success: false,
        message: e.toString(),
        count: 0,
        data: [],
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}