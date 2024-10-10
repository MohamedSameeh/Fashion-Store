List<String> maincateg = [
  'select category',
  'men',
  'woman',
  'kids',
];
List<String> men = [
  'subcategory',
  'New',
  'Clothes',
  'Shoes',
  'Accessories',
];

List<String> woman = [
  'subcategory',
  'New',
  'Clothes',
  'Shoes',
  'Accessories',
];

List<String> kids = [
  'subcategory',
  'New',
  'Clothes',
  'Shoes',
  'Accessories',
];

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||([0][\.]*))([0-9]{1,2}))$')
        .hasMatch(this);
  }
}

extension DiscountValidator on String {
  bool isValidDiscount() {
    return RegExp(r'^([0-9]*)$').hasMatch(this);
  }
}
