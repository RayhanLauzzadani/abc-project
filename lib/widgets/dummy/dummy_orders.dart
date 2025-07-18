import '../cart_and_order_list_card.dart';

class DummyOrder {
  final String storeName;
  final String orderId;
  final String productImage;
  final int itemCount;
  final int totalPrice;
  final DateTime orderDateTime;
  final OrderStatus status;

  DummyOrder({
    required this.storeName,
    required this.orderId,
    required this.productImage,
    required this.itemCount,
    required this.totalPrice,
    required this.orderDateTime,
    required this.status,
  });
}

final dummyOrdersInProgress = [
  DummyOrder(
    storeName: 'Nippon Mart',
    orderId: '2019482',
    productImage: 'assets/images/geprek.png',
    itemCount: 2,
    totalPrice: 24750,
    orderDateTime: DateTime(2024, 6, 30, 16, 15),
    status: OrderStatus.inProgress,
  ),
  DummyOrder(
    storeName: 'Nippon Mart',
    orderId: '2019483',
    productImage: 'assets/images/geprek.png',
    itemCount: 2,
    totalPrice: 50000,
    orderDateTime: DateTime(2024, 6, 30, 16, 15),
    status: OrderStatus.inProgress,
  ),
];

final dummyOrdersHistory = [
  DummyOrder(
    storeName: 'Nippon Mart',
    orderId: '2019482',
    productImage: 'assets/images/geprek.png',
    itemCount: 2,
    totalPrice: 50000,
    orderDateTime: DateTime(2024, 6, 30, 16, 15),
    status: OrderStatus.success,
  ),
  DummyOrder(
    storeName: 'Nippon Mart',
    orderId: '2019483',
    productImage: 'assets/images/geprek.png',
    itemCount: 2,
    totalPrice: 50000,
    orderDateTime: DateTime(2024, 6, 30, 16, 15),
    status: OrderStatus.success,
  ),
  DummyOrder(
    storeName: 'Nippon Mart',
    orderId: '2019484',
    productImage: 'assets/images/geprek.png',
    itemCount: 2,
    totalPrice: 50000,
    orderDateTime: DateTime(2024, 6, 30, 16, 15),
    status: OrderStatus.canceled,
  ),
];
