import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);
const _pink = Color(0xFFFBD9E8);

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
              // Header
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
                        Text(
                            con.hasProfile
                                ? 'My biodata'.tr
                                : 'Register profile'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        Text(
                            con.hasProfile
                                ? '${con.completion}% ${'complete'.tr}'
                                : 'Create your matchmaking profile'.tr,
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
                    for (var i = 0; i < con.bioSections.length; i++) ...[
                      _SectionHeader(
                          index: i + 1, title: con.bioSections[i].tr),
                      const SizedBox(height: 10),
                      ...con
                          .fieldsForSection(con.bioSections[i])
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _fieldWidget(context, con, f),
                              )),
                      // The photo/bio section also carries the file controls.
                      if (con.bioSections[i] ==
                          MatchmakingController.secPhoto)
                        _PhotoBioControls(con: con),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12.5, height: 1.45, color: _maroon),
                        children: [
                          TextSpan(
                              text: '${'Privacy'.tr}: ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          TextSpan(
                              text:
                                  'Your name & photos stay hidden until you accept someone\'s interest.'
                                      .tr),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Save button
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
                        : Text(
                            con.hasProfile
                                ? 'Update profile'.tr
                                : 'Register profile'.tr,
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

  Widget _fieldWidget(
      BuildContext context, MatchmakingController con, MmField f) {
    switch (f.type) {
      case MmFieldType.dropdown:
        return _Dropdown(con: con, field: f);
      case MmFieldType.date:
        return _DateField(con: con, field: f);
      default:
        return _TextField(con: con, field: f);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.index, required this.title});
  final int index;
  final String title;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: _pink, shape: BoxShape.circle),
            child: Text('$index',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _maroon)),
          ),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF334155))),
        ],
      );
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

class _Box extends StatelessWidget {
  const _Box({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: child,
      );
}

class _TextField extends StatelessWidget {
  const _TextField({required this.con, required this.field});
  final MatchmakingController con;
  final MmField field;
  @override
  Widget build(BuildContext context) {
    return _Box(
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
              hintText: '${'Enter'.tr} ${field.label.toLowerCase()}',
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

class _DateField extends StatelessWidget {
  const _DateField({required this.con, required this.field});
  final MatchmakingController con;
  final MmField field;
  @override
  Widget build(BuildContext context) {
    final value = con.textCtrl(field.key).text;
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = DateTime.tryParse(value) ??
            DateTime(now.year - 25, now.month, now.day);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1940),
          lastDate: now,
        );
        if (picked != null) {
          con.textCtrl(field.key).text =
              '${picked.year.toString().padLeft(4, '0')}-'
              '${picked.month.toString().padLeft(2, '0')}-'
              '${picked.day.toString().padLeft(2, '0')}';
          con.update();
        }
      },
      child: _Box(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(field.label, required: field.required),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(value.isEmpty ? 'YYYY-MM-DD' : value,
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: value.isEmpty
                              ? const Color(0xFFB8C0CC)
                              : const Color(0xFF0F172A))),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
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
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(field.label, required: field.required),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (value != null && options.contains(value)) ? value : null,
              hint: Text('${'Select'.tr} ${field.label.toLowerCase()}',
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

/// Photo visibility toggle + photo picker + bio-data PDF picker + the list of
/// already-uploaded documents.
class _PhotoBioControls extends StatelessWidget {
  const _PhotoBioControls({required this.con});
  final MatchmakingController con;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        // Photo + visibility
        _Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Photo (optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: con.pickPhoto,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: _pink,
                          borderRadius: BorderRadius.circular(12),
                          image: con.photoFile != null
                              ? DecorationImage(
                                  image: FileImage(con.photoFile!),
                                  fit: BoxFit.cover)
                              : null),
                      child: con.photoFile == null
                          ? const Icon(Icons.add_a_photo_outlined,
                              color: _maroon, size: 22)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        con.photoFile != null
                            ? 'Photo selected · tap to change'.tr
                            : 'Tap to add a profile photo'.tr,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF64748B))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: _maroon,
                value: con.photoVisible,
                onChanged: con.setPhotoVisible,
                title: Text('Make photo visible to other profiles'.tr,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Bio-data PDF
        _Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Bio-data PDF (optional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: con.pickBioDataPdf,
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded,
                        size: 18, color: _maroon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          con.bioDataName.isNotEmpty
                              ? con.bioDataName
                              : 'Choose PDF file'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: con.bioDataName.isNotEmpty
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8))),
                    ),
                  ],
                ),
              ),
              Text('PDF only · uploaded for verification'.tr,
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        // Existing documents
        if (con.documents.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...con.documents.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Box(
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined,
                          size: 18, color: _maroon),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.kindLabel,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                            if (d.remarks.isNotEmpty)
                              Text(d.remarks,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(d.status,
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0369A1))),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
