import '../../domain/entities/warehouse.dart';

class WarehouseModel extends Warehouse {
  const WarehouseModel({
    required super.id,
    required super.name,
    required super.location,
    required super.capacity,
    required super.managerName,
    required super.contactInfo,
  });

  factory WarehouseModel.fromMap(Map<String, dynamic> map) {
    return WarehouseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      capacity: map['capacity'] as int,
      managerName: map['manager_name'] as String,
      contactInfo: map['contact_info'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'manager_name': managerName,
      'contact_info': contactInfo,
    };
  }

  factory WarehouseModel.fromEntity(Warehouse warehouse) {
    return WarehouseModel(
      id: warehouse.id,
      name: warehouse.name,
      location: warehouse.location,
      capacity: warehouse.capacity,
      managerName: warehouse.managerName,
      contactInfo: warehouse.contactInfo,
    );
  }
}
