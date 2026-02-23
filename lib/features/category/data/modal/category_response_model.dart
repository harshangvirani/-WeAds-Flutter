class CategoryResponse {
  final List<CategoryData>? data;
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  CategoryResponse({
    this.data,
    this.code,
    this.statusValue,
    this.statusMessage,
  });

  CategoryResponse copyWith({
    List<CategoryData>? data,
    int? code,
    String? statusValue,
    String? statusMessage,
  }) {
    return CategoryResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      data: json['data'] != null
          ? List<CategoryData>.from(
              json['data'].map((x) => CategoryData.fromJson(x)),
            )
          : null,
      code: json['code'],
      statusValue: json['statusValue'],
      statusMessage: json['statusMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'code': code,
      'statusValue': statusValue,
      'statusMessage': statusMessage,
    };
  }
}

class CategoryData {
  final int? categoryId;
  final String? categoryName;
  final String? categoryDescription;
  final DateTime? createdOn;
  final bool? isActive;

  CategoryData({
    this.categoryId,
    this.categoryName,
    this.categoryDescription,
    this.createdOn,
    this.isActive,
  });

  CategoryData copyWith({
    int? categoryId,
    String? categoryName,
    String? categoryDescription,
    DateTime? createdOn,
    bool? isActive,
  }) {
    return CategoryData(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      createdOn: createdOn ?? this.createdOn,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      categoryDescription: json['categoryDescription'],
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'])
          : null,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryDescription': categoryDescription,
      'createdOn': createdOn?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
