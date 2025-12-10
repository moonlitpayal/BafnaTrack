class Flat {
  final String id;
  final String projectId;
  final String flatNo;
  final String? status;
  final double? area;
  final double? price;
  final String? floor;
  final String? block;
  final String? facing;
  final String? ownerName;
  final String? bhkType;
  final bool? parking;

  const Flat({
    required this.id,
    required this.projectId,
    required this.flatNo,
    this.status,
    this.area,
    this.price,
    this.floor,
    this.block,
    this.facing,
    this.ownerName,
    this.bhkType,
    this.parking,
  });

  factory Flat.fromJson(Map<String, dynamic> json) {
    return Flat(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      flatNo: json['flat_no'] as String,
      status: json['status'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      floor: json['floor'] as String?,
      block: json['block'] as String?,
      facing: json['facing'] as String?,
      ownerName: json['owner_name'] as String?,
      bhkType: json['bhk_type'] as String?,
      parking: json['parking'] as bool?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'flat_no': flatNo,
      'status': status,
      'area': area,
      'price': price,
      'floor': floor,
      'block': block,
      'facing': facing,
      'owner_name': ownerName,
      'bhk_type': bhkType,
      'parking': parking,
    };
  }

  Flat copyWith({
    String? id,
    String? projectId,
    String? flatNo,
    String? status,
    double? area,
    double? price,
    String? floor,
    String? block,
    String? facing,
    String? ownerName,
    String? bhkType,
    bool? parking,
  }) {
    return Flat(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      flatNo: flatNo ?? this.flatNo,
      status: status ?? this.status,
      area: area ?? this.area,
      price: price ?? this.price,
      floor: floor ?? this.floor,
      block: block ?? this.block,
      facing: facing ?? this.facing,
      ownerName: ownerName ?? this.ownerName,
      bhkType: bhkType ?? this.bhkType,
      parking: parking ?? this.parking,
    );
  }
}
