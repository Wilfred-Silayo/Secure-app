import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_jailbreak_detection/Flutter_jailbreak_detection.dart';

final developerOptionProvider = StateNotifierProvider<DeveloperOptionNotifier, bool>(
  (ref) => DeveloperOptionNotifier(),
);

class DeveloperOptionNotifier extends StateNotifier<bool> {
  DeveloperOptionNotifier() : super(false) {
    checkDeveloperOptions();
  }

  // Check developer options state
  Future<void> checkDeveloperOptions() async {
    try {
      bool isDeveloperOptionsEnabled = await FlutterJailbreakDetection.developerMode;
      state = isDeveloperOptionsEnabled;
    } catch (e) {
      // Handle exception if any
      state = false;
    }
  }
}
