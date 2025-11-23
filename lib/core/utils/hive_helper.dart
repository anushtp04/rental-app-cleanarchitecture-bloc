import 'package:hive_flutter/hive_flutter.dart';
import '../const/hive_box_names.dart';
import '../../data/models/rental_model.dart';

class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter (will be available after running build_runner)
    // Run: flutter pub run build_runner build
    if (!Hive.isAdapterRegistered(0)) {
      try {
        Hive.registerAdapter(RentalModelAdapter());
      } catch (e) {
        // Adapter not generated yet - run build_runner first
        throw Exception(
          'RentalModelAdapter not found. Please run: flutter pub run build_runner build',
        );
      }
    }
    
    // Handle schema migration - clear box if it exists with old schema
    try {
      // Check if box is already open, close it first
      if (Hive.isBoxOpen(HiveBoxNames.rentals)) {
        await Hive.box<RentalModel>(HiveBoxNames.rentals).close();
      }
      await Hive.openBox<RentalModel>(HiveBoxNames.rentals);
    } catch (e) {
      // If opening fails due to schema mismatch, delete the old box and recreate
      try {
        if (Hive.isBoxOpen(HiveBoxNames.rentals)) {
          await Hive.box(HiveBoxNames.rentals).close();
        }
        await Hive.deleteBoxFromDisk(HiveBoxNames.rentals);
      } catch (_) {
        // Ignore errors when deleting
      }
      await Hive.openBox<RentalModel>(HiveBoxNames.rentals);
    }
    
    await Hive.openBox(HiveBoxNames.theme);
  }

  static Box<RentalModel> get rentalBox => Hive.box<RentalModel>(HiveBoxNames.rentals);
  static Box get themeBox => Hive.box(HiveBoxNames.theme);
}
