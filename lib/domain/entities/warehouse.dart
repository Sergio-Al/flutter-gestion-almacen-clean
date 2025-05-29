class Warehouse {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final String managerName;
  final String contactInfo;

  const Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.managerName,
    required this.contactInfo,
  });

  Warehouse copyWith({
    String? id,
    String? name,
    String? location,
    int? capacity,
    String? managerName,
    String? contactInfo,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      managerName: managerName ?? this.managerName,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Warehouse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
