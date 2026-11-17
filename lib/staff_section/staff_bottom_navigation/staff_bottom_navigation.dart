import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_home_section/staff_home_screen.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_my_entires/staff_my_entires_screen.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_profile_section/staff_profile_section.dart';
import 'package:superapp/view_model/api_controllers/ui_controllers/bottomNavigation_controller.dart';

class StaffBottomNavigation extends StatefulWidget {
  const StaffBottomNavigation({super.key});

  @override
  State<StaffBottomNavigation> createState() => _StaffBottomNavigationState();
}

class _StaffBottomNavigationState extends State<StaffBottomNavigation> {
  int selected = 0;

  // ✅ 3 tabs only: Home, My Entries, Profile
  final List<Widget> _pages = <Widget>[
    StaffHomeScreen(),
    StaffMyEntriesScreen(),
    StaffProfileSection(),
  ];

  // ✅ Labels for the 3 tabs
  final List<String> _labels = ["Home", "My Entries", "Profile"];

  // ✅ Icons for the 3 tabs
  final List<IconData> _icons = [
    LineIcons.home,
    LineIcons.fileAlt,
    LineIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController bottomNavigationController =
        Get.find<BottomNavigationController>();

    return PopScope(
      canPop: selected == 0,
      onPopInvoked: (didPop) {
        if (!didPop && selected != 0) {
          setState(() {
            selected = 0;
          });
          bottomNavigationController.updateSelectedIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: _pages[selected],
        bottomNavigationBar: Container(
          color: AppColors.whiteColor,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_labels.length, (index) {
                  final isSelected = selected == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          selected = index;
                          bottomNavigationController.updateSelectedIndex(index);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon on top
                            Icon(
                              _icons[index],
                              size: 22,
                              color:
                                  isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade600,
                            ),
                            // Label below — only shows when selected
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child:
                                  isSelected
                                      ? Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: CustomText(
                                          textName: _labels[index],
                                          fontFamily: FontFamily.poppins,
                                          fontSize: 12,
                                          textColor: AppColors.primaryColor,
                                          fontWeightType:
                                              FontWeightType.bold,
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
