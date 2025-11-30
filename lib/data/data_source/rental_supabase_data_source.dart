import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rental_model.dart';
import '../../core/service/supabase_auth_service.dart';
import '../../core/service/supabase_storage_service.dart';

abstract class RentalSupabaseDataSource {
  Future<List<RentalModel>> getAllRentals();
  Future<RentalModel> getRentalById(String id);
  Future<void> cacheRental(RentalModel rental);
  Future<void> updateCachedRental(RentalModel rental);
  Future<void> deleteRental(String id);
  Future<void> deleteAllRentals();
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  });
}

class RentalSupabaseDataSourceImpl implements RentalSupabaseDataSource {
  final SupabaseClient supabase;
  final SupabaseAuthService authService;
  final SupabaseStorageService storageService;

  RentalSupabaseDataSourceImpl({
    required this.supabase,
    required this.authService,
    required this.storageService,
  });

  String get _userId => authService.currentUser?.id ?? '';

  @override
  Future<List<RentalModel>> getAllRentals() async {
    try {
      final response = await supabase
          .from('rentals')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RentalModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get rentals: $e');
    }
  }

  @override
  Future<RentalModel> getRentalById(String id) async {
    try {
      final response = await supabase
          .from('rentals')
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .single();

      return RentalModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to get rental: $e');
    }
  }

  @override
  Future<void> cacheRental(RentalModel rental) async {
    try {
      final rentalData = rental.toSupabase();
      rentalData['user_id'] = _userId;
      
      // Upload image to cloud storage if local path exists
      if (rental.imagePath != null && !storageService.isCloudUrl(rental.imagePath)) {
        final cloudUrl = await storageService.uploadRentalImage(rental.imagePath!, rental.id);
        rentalData['image_path'] = cloudUrl;
      }
      
      // Upload document to cloud storage if local path exists
      if (rental.documentPath != null && !storageService.isCloudUrl(rental.documentPath)) {
        final cloudUrl = await storageService.uploadRentalDocument(rental.documentPath!, rental.id);
        rentalData['document_path'] = cloudUrl;
      }
      
      await supabase.from('rentals').insert(rentalData);
    } catch (e) {
      throw Exception('Failed to add rental: $e');
    }
  }

  @override
  Future<void> updateCachedRental(RentalModel rental) async {
    try {
      final rentalData = rental.toSupabase();
      
      // Upload new image to cloud storage if local path exists
      if (rental.imagePath != null && !storageService.isCloudUrl(rental.imagePath)) {
        final cloudUrl = await storageService.uploadRentalImage(rental.imagePath!, rental.id);
        rentalData['image_path'] = cloudUrl;
      }
      
      // Upload new document to cloud storage if local path exists
      if (rental.documentPath != null && !storageService.isCloudUrl(rental.documentPath)) {
        final cloudUrl = await storageService.uploadRentalDocument(rental.documentPath!, rental.id);
        rentalData['document_path'] = cloudUrl;
      }
      
      await supabase
          .from('rentals')
          .update(rentalData)
          .eq('id', rental.id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('Failed to update rental: $e');
    }
  }

  @override
  Future<void> deleteRental(String id) async {
    try {
      // Delete files from storage first
      await storageService.deleteRentalFiles(id);
      
      // Then delete from database
      await supabase
          .from('rentals')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('Failed to delete rental: $e');
    }
  }

  @override
  Future<void> deleteAllRentals() async {
    try {
      await supabase
          .from('rentals')
          .delete()
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('Failed to delete all rentals: $e');
    }
  }

  @override
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  }) async {
    try {
      var query = supabase
          .from('rentals')
          .select()
          .eq('user_id', _userId);

      if (fromDate != null) {
        query = query.gte('rent_from_date', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('rent_to_date', toDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      
      List<RentalModel> rentals = (response as List)
          .map((json) => RentalModel.fromSupabase(json as Map<String, dynamic>))
          .toList();

      // Client-side filtering for text fields
      if (vehicleNumber != null && vehicleNumber.isNotEmpty) {
        rentals = rentals.where((rental) {
          return rental.vehicleNumber.toLowerCase().contains(vehicleNumber.toLowerCase());
        }).toList();
      }

      if (ownerName != null && ownerName.isNotEmpty) {
        rentals = rentals.where((rental) {
          return rental.rentToPerson.toLowerCase().contains(ownerName.toLowerCase());
        }).toList();
      }

      return rentals;
    } catch (e) {
      throw Exception('Failed to filter rentals: $e');
    }
  }
}
