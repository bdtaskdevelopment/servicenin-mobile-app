import 'bn/common_bn.dart';
import 'bn/core_bn.dart';
import 'bn/extra_bn.dart';
import 'bn/group_a_bn.dart';
import 'bn/group_b_bn.dart';
import 'bn/group_c_bn.dart';
import 'bn/group_d_bn.dart';

/// All Bangla translations merged. Keys are the English source text, so English
/// mode simply falls back to the key. Each module group lives in its own file
/// under `bn/` and is merged here.
final Map<String, String> snBn = {
  ...commonBn,
  ...coreBn,
  ...extraBn,
  ...groupABn,
  ...groupBBn,
  ...groupCBn,
  ...groupDBn,
};

/// English map is intentionally empty: with English source text as keys, the
/// fallback returns the key itself (the English string).
const Map<String, String> snEn = {};
