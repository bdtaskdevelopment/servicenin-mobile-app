import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/registration_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/dob_picker_sheet.dart';
import '../../widgets/gender_selector.dart';
import '../../widgets/select_field.dart';

class StepAbout extends StatelessWidget {
  const StepAbout({super.key});

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
                'Tell us about yourself'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You only need to do this once.'.tr,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Enter your full name'.tr,
                required: true,
                controller: con.nameController,
                onChanged: con.onNameChanged,
              ),
              const SizedBox(height: 14),
              SelectField(
                label: 'Date of birth'.tr,
                required: true,
                value: con.dobLabel,
                placeholder: '',
                onTap: () async {
                  final picked =
                      await DobPickerSheet.show(initial: con.dob);
                  if (picked != null) con.setDob(picked);
                },
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Gender'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Color(0xFFE53E3E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GenderSelector(
                options: RegistrationController.genders,
                selected: con.gender,
                onSelected: con.setGender,
              ),
            ],
          ),
        );
      },
    );
  }
}
