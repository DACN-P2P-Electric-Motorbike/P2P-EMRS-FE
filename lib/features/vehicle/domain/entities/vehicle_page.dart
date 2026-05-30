import 'package:equatable/equatable.dart';

import 'vehicle_entity.dart';

class VehiclePage extends Equatable {
  final List<VehicleEntity> vehicles;
  final int total;

  const VehiclePage({required this.vehicles, required this.total});

  @override
  List<Object?> get props => [vehicles, total];
}
