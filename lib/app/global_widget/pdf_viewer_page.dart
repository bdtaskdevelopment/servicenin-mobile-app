import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/values/app_colors.dart';

/// Full-screen in-app PDF viewer — renders raw PDF bytes with [PdfPreview]
/// so invoices open inside the app instead of handing off to an external
/// viewer app (which may not exist on the device).
class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.bytes, this.title = 'Invoice'});

  final Uint8List bytes;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: PdfPreview(
        build: (format) async => bytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
