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
  final String? parking;
  final String? notes;
  final String? customerPhone;
  final String? quotationImagePath;


  final double? agreementValue;
  final double? extraWorkAmount;
  final double? amountPaidTillDate;
  final bool? hasLoan;
  final double? loanAmount;
  final double? projectCompletionPercentage;

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
    this.notes,
    this.customerPhone,
    this.quotationImagePath,

    this.agreementValue,
    this.extraWorkAmount,
    this.amountPaidTillDate,
    this.hasLoan,
    this.loanAmount,
    this.projectCompletionPercentage,
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
      parking: json['parking'] as String?,
      notes: json['notes'] as String?,
      customerPhone: json['customer_phone'] as String?,
      quotationImagePath: json['quotation_image_path'] as String?,

      agreementValue: (json['agreement_value'] as num?)?.toDouble(),
      extraWorkAmount: (json['extra_work_amount'] as num?)?.toDouble(),
      amountPaidTillDate: (json['amount_paid_till_date'] as num?)?.toDouble(),
      hasLoan: json['has_loan'] as bool?,
      loanAmount: (json['loan_amount'] as num?)?.toDouble(),
      projectCompletionPercentage: (json['project_completion_percentage'] as num?)?.toDouble(),
    );
  }

  Flat copyWith({String? status}) {
    return Flat(
      id: id,
      projectId: projectId,
      flatNo: flatNo,
      status: status ?? this.status,
      area: area,
      price: price,
      floor: floor,
      block: block,
      facing: facing,
      ownerName: ownerName,
      bhkType: bhkType,
      parking: parking,
      notes: notes,
      customerPhone: customerPhone,
      quotationImagePath: quotationImagePath,
      agreementValue: agreementValue,
      extraWorkAmount: extraWorkAmount,
      amountPaidTillDate: amountPaidTillDate,
      hasLoan: hasLoan,
      loanAmount: loanAmount,
      projectCompletionPercentage: projectCompletionPercentage,
    );
  }
}