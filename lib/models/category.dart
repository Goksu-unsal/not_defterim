class Category {
  Category({
    this.categoryName,
  });

  Category.withId({this.categoryId,this.categoryName});

  int categoryId;
  String categoryName;

  factory Category.fromMap(Map<String, dynamic> map) => Category.withId(
    categoryId: map["category_id"] == null ? null : map["category_id"],
    categoryName: map["category_name"] == null ? null : map["category_name"],
  );

  Map<String, dynamic> toMap() => {
    "category_id": categoryId == null ? null : categoryId,
    "category_name": categoryName == null ? null : categoryName,
  };

  @override
  String toString() {
    return 'Category{categoryId: $categoryId, categoryName: $categoryName}';
  }
}