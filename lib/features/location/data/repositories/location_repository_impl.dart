
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/location_repository.dart';

@Injectable(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Either<Failure, UserLocationEntity>> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure(message: 'Location services are disabled.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(LocationFailure(message: 'Location permission denied.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationFailure(message: 'Location permission permanently denied.'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode to get human-readable address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? address;
      String? city;
      String? country;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [
          if (place.street != null && place.street!.isNotEmpty) place.street!,
          if (place.subLocality != null &&
              place.subLocality!.isNotEmpty &&
              place.subLocality != place.street) place.subLocality!,
        ];

        address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : place.name;

        city = place.locality;
        country = place.country;
      }

      return Right(UserLocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        country: country,
      ));
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }
}