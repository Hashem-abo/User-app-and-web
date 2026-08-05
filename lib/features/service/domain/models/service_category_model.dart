class ServiceCategoryModel {
  int? id;
  String? name;
  String? imageFullUrl;
  int? parentId;
  int? position;
  int? shelfId;
  int? moduleId;
  int? priority;
  bool? status;
  List<ServiceCategoryModel>? childes;

  ServiceCategoryModel({
    this.id,
    this.name,
    this.imageFullUrl,
    this.parentId,
    this.position,
    this.shelfId,
    this.moduleId,
    this.priority,
    this.status,
    this.childes,
  });

  ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    parentId = json['parent_id'];
    position = json['position'];
    shelfId = json['shelf_id'];
    moduleId = json['module_id'];
    priority = json['priority'];
    status = json['status'] == 1 || json['status'] == true;
    if (json['childes'] != null) {
      childes = <ServiceCategoryModel>[];
      json['childes'].forEach((v) {
        childes!.add(ServiceCategoryModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['parent_id'] = parentId;
    data['position'] = position;
    data['shelf_id'] = shelfId;
    data['module_id'] = moduleId;
    data['priority'] = priority;
    data['status'] = status;
    if (childes != null) {
      data['childes'] = childes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
