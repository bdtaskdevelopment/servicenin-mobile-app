import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_colors.dart';
import '../../controllers/registration_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/select_field.dart';
import '../../widgets/selection_bottom_sheet.dart';

class StepLocation extends StatelessWidget {
  const StepLocation({super.key});

  // Sample location data — replace with API-driven lists when available.
  static const List<String> divisions = [
    'ঢাকা', 'চট্টগ্রাম', 'সিলেট', 'রাজশাহী',
    'খুলনা', 'বরিশাল', 'রংপুর', 'ময়মনসিংহ',
  ];
  static const List<String> districts = [
    'ঢাকা', 'গাজীপুর', 'নারায়ণগঞ্জ', 'টাঙ্গাইল', 'কিশোরগঞ্জ', 'মানিকগঞ্জ',
  ];
  static const List<String> thanas = [
    'গুলশান', 'বনানী', 'ধানমন্ডি', 'মিরপুর', 'উত্তরা', 'মোহাম্মদপুর',
  ];
  static const List<String> areas = [
    'গুলশান-১', 'গুলশান-২', 'বাড্ডা', 'নিকেতন', 'বারিধারা',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (con) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where do you live?'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We need this to bring services to your area.'.tr,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              SelectField(
                label: 'Division'.tr,
                leadingIcon: Icons.location_on_outlined,
                centerText: true,
                value: con.division,
                placeholder: 'Select division'.tr,
                onTap: () async {
                  final v = await SelectionBottomSheet.show(
                      'Select division'.tr, divisions,
                      selected: con.division);
                  if (v != null) con.setDivision(v);
                },
              ),
              const SizedBox(height: 12),
              SelectField(
                label: 'District'.tr,
                leadingIcon: Icons.location_on_outlined,
                centerText: true,
                value: con.district,
                placeholder: 'Select district'.tr,
                onTap: () async {
                  final v = await SelectionBottomSheet.show(
                      'Select district'.tr, districts,
                      selected: con.district);
                  if (v != null) con.setDistrict(v);
                },
              ),
              const SizedBox(height: 12),
              SelectField(
                label: 'Upazila / Thana'.tr,
                leadingIcon: Icons.location_on_outlined,
                centerText: true,
                value: con.thana,
                placeholder: 'Select thana'.tr,
                onTap: () async {
                  final v = await SelectionBottomSheet.show(
                      'Select thana'.tr, thanas,
                      selected: con.thana);
                  if (v != null) con.setThana(v);
                },
              ),
              const SizedBox(height: 12),
              SelectField(
                label: 'Union / Area'.tr,
                leadingIcon: Icons.location_on_outlined,
                centerText: true,
                value: con.area,
                placeholder: 'Select area'.tr,
                onTap: () async {
                  final v = await SelectionBottomSheet.show(
                      'Select area'.tr, areas,
                      selected: con.area);
                  if (v != null) con.setArea(v);
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: con.useCurrentLocation,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location_rounded,
                          size: 18, color: AppColors.brandOrange),
                      const SizedBox(width: 6),
                      Text(
                        'Use my current location'.tr,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.brandOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'Address (optional)'.tr,
                      controller: con.addressController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      label: 'Postcode'.tr,
                      controller: con.postcodeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
