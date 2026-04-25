import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';

class CartItem {
  final ProductEntity product;
  final RxInt quantity;
  CartItem({required this.product, int qty = 1}) : quantity = qty.obs;
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

  void addItem(ProductEntity product, {int quantity = 1}) {
    final existing = items.firstWhereOrNull((i) => i.product.id == product.id);
    if (existing != null) {
      existing.quantity.value += quantity;
    } else {
      items.add(CartItem(product: product, qty: quantity));
    }
    items.refresh();
  }

  void removeItem(String productId) {
    items.removeWhere((i) => i.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final item = items.firstWhereOrNull((i) => i.product.id == productId);
    if (item != null) {
      item.quantity.value = quantity;
      items.refresh();
    }
  }

  void incrementQuantity(String productId) {
    final item = items.firstWhereOrNull((i) => i.product.id == productId);
    if (item != null) {
      item.quantity.value++;
      items.refresh();
    }
  }

  void decrementQuantity(String productId) {
    final item = items.firstWhereOrNull((i) => i.product.id == productId);
    if (item != null) {
      if (item.quantity.value > 1) {
        item.quantity.value--;
        items.refresh();
      } else {
        removeItem(productId);
      }
    }
  }

  void clearCart() => items.clear();

  bool isInCart(String productId) =>
      items.any((i) => i.product.id == productId);
}
