import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';

class CartItem {
  final String key;
  final ProductEntity product;
  final RxInt quantity;
  CartItem({required this.key, required this.product, int qty = 1}) : quantity = qty.obs;
  double get total => product.price * quantity.value;
}

class CartController extends GetxController {
  final items = <CartItem>[].obs;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get shipping => items.isEmpty ? 0 : (subtotal > 5000 ? 0 : 100);

  double get tax => subtotal * 0.10;

  double get total => subtotal + shipping + tax;

  bool get isEmpty => items.isEmpty;

  String itemKeyFor(ProductEntity product) =>
      (product.catalogId != null && product.catalogId! > 0)
          ? product.catalogId!.toString()
          : product.id;

  int getItemCount(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    return item?.quantity.value ?? 0;
  }
  void addItem(ProductEntity product, {int quantity = 1}) {
    final key = itemKeyFor(product);
    final existing = items.firstWhereOrNull((i) => i.key == key);
    if (existing != null) {
      existing.quantity.value += quantity;
    } else {
      items.add(CartItem(key: key, product: product, qty: quantity));
    }
    items.refresh();
  }

  void removeItem(String key) {
    items.removeWhere((i) => i.key == key);
  }

  void updateQuantity(String key, int quantity) {
    if (quantity <= 0) {
      removeItem(key);
      return;
    }
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      item.quantity.value = quantity;
      items.refresh();
    }
  }

  void incrementQuantity(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      item.quantity.value++;
      items.refresh();
    }
  }

  void decrementQuantity(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      if (item.quantity.value > 1) {
        item.quantity.value--;
        items.refresh();
      } else {
        removeItem(key);
      }
    }
  }

  void clearCart() => items.clear();

  bool isInCart(String key) => items.any((i) => i.key == key);
}
