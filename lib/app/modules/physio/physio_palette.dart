import 'package:flutter/material.dart';

/// One center's visual identity: a saturated accent, a matching light
/// tile tone for icon backgrounds/chips, and an icon to pair with it —
/// cycled across centers so the picker and catalog read as a set of
/// distinct places rather than one repeated brown card.
class PhysioCenterStyle {
  const PhysioCenterStyle(this.accent, this.tile, this.icon);
  final Color accent;
  final Color tile;
  final IconData icon;
}

const List<PhysioCenterStyle> physioCenterPalette = [
  PhysioCenterStyle(
      Color(0xFF4F46E5), Color(0xFFEEF2FF), Icons.local_hospital_rounded),
  PhysioCenterStyle(
      Color(0xFF0D9488), Color(0xFFF0FDFA), Icons.healing_rounded),
  PhysioCenterStyle(
      Color(0xFFE11D48), Color(0xFFFFF1F2), Icons.favorite_rounded),
  PhysioCenterStyle(
      Color(0xFFD97706), Color(0xFFFFFBEB), Icons.directions_run_rounded),
  PhysioCenterStyle(
      Color(0xFF7C3AED), Color(0xFFF5F3FF), Icons.auto_awesome_rounded),
  PhysioCenterStyle(
      Color(0xFF0891B2), Color(0xFFECFEFF), Icons.water_drop_rounded),
  PhysioCenterStyle(Color(0xFFDB2777), Color(0xFFFDF2F8), Icons.spa_rounded),
  PhysioCenterStyle(Color(0xFF059669), Color(0xFFECFDF5), Icons.eco_rounded),
];

/// Deterministic style for a center id — the same center always gets the
/// same color/icon everywhere (picker, detail header, catalog), whatever
/// order the list comes back in.
PhysioCenterStyle physioStyleFor(String centerId) {
  if (centerId.isEmpty) return physioCenterPalette.first;
  final i = centerId.hashCode.abs() % physioCenterPalette.length;
  return physioCenterPalette[i];
}
