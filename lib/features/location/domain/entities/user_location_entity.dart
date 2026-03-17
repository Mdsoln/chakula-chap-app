
import 'package:equatable/equatable.dart';

class UserLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;     // human-readable, e.g. "Livingstone, Kariakoo"
  final String? city;
  final String? country;

  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  String get displayName => address ?? '$latitude, $longitude';

  @override
  List<Object?> get props => [latitude, longitude, address];
}