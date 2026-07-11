/// Web device info — no RAM detection, use generous defaults.

enum SocFamily {
  apple,
  snapdragon,
  mediatek,
  exynos,
  googleTensor,
  unisoc,
  rockchip,
  hisilicon,
  unknown,
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  return {
    'totalRamGB': 8.0,
    'availableRamGB': 4.0,
    'isTensorSoC': 0.0,
    'socFamily': 8, // unknown
    'socHardware': '',
  };
}
