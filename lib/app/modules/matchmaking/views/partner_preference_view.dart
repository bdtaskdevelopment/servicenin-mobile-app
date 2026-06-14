import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);

/// Partner preference form — PUT /matchmaking/profiles/me/preference.
class PartnerPreferenceView extends GetView<MatchmakingController> {
  const PartnerPreferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<MatchmakingController>(
          builder: (con) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Partner preference'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        Text('Tell us who you\'re looking for'.tr,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _NumField(
                                con: con, key_: 'age_min', label: 'Age min')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _NumField(
                                con: con, key_: 'age_max', label: 'Age max')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DropField(
                        con: con,
                        key_: 'gender',
                        label: 'Gender',
                        optionsKey: 'genders'),
                    const SizedBox(height: 12),
                    _DropField(
                        con: con,
                        key_: 'marital_status',
                        label: 'Marital status',
                        optionsKey: 'marital_status'),
                    const SizedBox(height: 12),
                    _TxtField(con: con, key_: 'religion', label: 'Religion'),
                    const SizedBox(height: 12),
                    _TxtField(
                        con: con, key_: 'education', label: 'Education'),
                    const SizedBox(height: 12),
                    _TxtField(
                        con: con,
                        key_: 'profession',
                        label: 'Profession (comma separated)'),
                    const SizedBox(height: 12),
                    _TxtField(
                        con: con,
                        key_: 'location',
                        label: 'Location (comma separated)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _NumField(
                                con: con,
                                key_: 'height_min_cm',
                                label: 'Height min (cm)')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _NumField(
                                con: con,
                                key_: 'height_max_cm',
                                label: 'Height max (cm)')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TxtField(
                        con: con,
                        key_: 'income_range',
                        label: 'Income range'),
                    const SizedBox(height: 12),
                    _TxtField(con: con, key_: 'lifestyle', label: 'Lifestyle'),
                    const SizedBox(height: 12),
                    _DropField(
                        con: con,
                        key_: 'family_type',
                        label: 'Family type',
                        optionsKey: 'family_types'),
                    const SizedBox(height: 12),
                    _TxtField(
                        con: con,
                        key_: 'notes',
                        label: 'Notes',
                        multiline: true),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        con.savingPreference ? null : con.savePreference,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.savingPreference
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Save preferences'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: child,
      );
}

class _TxtField extends StatelessWidget {
  const _TxtField(
      {required this.con,
      required this.key_,
      required this.label,
      this.multiline = false});
  final MatchmakingController con;
  final String key_;
  final String label;
  final bool multiline;
  @override
  Widget build(BuildContext context) => _Shell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(label),
            TextField(
              controller: con.prefCtrl(key_),
              maxLines: multiline ? 3 : 1,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: '${'Enter'.tr} ${label.toLowerCase()}',
                hintStyle: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB8C0CC)),
              ),
            ),
          ],
        ),
      );
}

class _NumField extends StatelessWidget {
  const _NumField(
      {required this.con, required this.key_, required this.label});
  final MatchmakingController con;
  final String key_;
  final String label;
  @override
  Widget build(BuildContext context) => _Shell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(label),
            TextField(
              controller: con.prefCtrl(key_),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: '—',
                hintStyle: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB8C0CC)),
              ),
            ),
          ],
        ),
      );
}

class _DropField extends StatelessWidget {
  const _DropField(
      {required this.con,
      required this.key_,
      required this.label,
      required this.optionsKey});
  final MatchmakingController con;
  final String key_;
  final String label;
  final String optionsKey;
  @override
  Widget build(BuildContext context) {
    final options = con.optionsFor(optionsKey);
    final value = con.prefChoice[key_];
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (value != null && options.contains(value)) ? value : null,
              hint: Text('${'Select'.tr} ${label.toLowerCase()}',
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB8C0CC))),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(mmHumanize(o),
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) con.setPrefChoice(key_, v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
