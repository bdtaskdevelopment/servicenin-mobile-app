import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);

class MyBiodataView extends GetView<MatchmakingController> {
  const MyBiodataView({super.key});

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
                        const Text('My biodata',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        Text(
                            con.hasProfile
                                ? '${con.completion}% complete'
                                : 'Create your profile',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: con.hasProfile ? con.completion / 100 : 0.0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE9ECF1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_maroon),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    ...con.bioFields.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: f.type == MmFieldType.dropdown
                              ? _Dropdown(con: con, field: f)
                              : _TextField(con: con, field: f),
                        )),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 12.5, height: 1.45, color: _maroon),
                        children: [
                          TextSpan(
                              text: 'Privacy: ',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(
                              text:
                                  'Your name & photos stay hidden until you accept someone\'s interest.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.savingBiodata ? null : con.saveBiodata,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.savingBiodata
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(con.hasProfile ? 'Update biodata' : 'Save biodata',
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
  const _Label(this.text, {this.required = false});
  final String text;
  final bool required;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6)),
          if (required)
            const Text(' *',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _maroon)),
        ],
      );
}

class _TextField extends StatelessWidget {
  const _TextField({required this.con, required this.field});
  final MatchmakingController con;
  final MmField field;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(field.label, required: field.required),
          TextField(
            controller: con.textCtrl(field.key),
            keyboardType: field.type == MmFieldType.number
                ? TextInputType.number
                : (field.type == MmFieldType.multiline
                    ? TextInputType.multiline
                    : TextInputType.text),
            maxLines: field.type == MmFieldType.multiline ? 3 : 1,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: 'Enter ${field.label.toLowerCase()}',
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
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.con, required this.field});
  final MatchmakingController con;
  final MmField field;
  @override
  Widget build(BuildContext context) {
    final options = con.optionsFor(field.optionsKey);
    final value = con.choice[field.key];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(field.label, required: field.required),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (value != null && options.contains(value)) ? value : null,
              hint: Text('Select ${field.label.toLowerCase()}',
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
                if (v != null) con.setChoice(field.key, v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
