import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grocery_app/models/sales.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage ss = FirebaseStorage.instance;

class StoreDb {
  Future<bool> addToCart(DocumentReference productId, int numItem) async {
    var cart = await db.collection('carts').doc(auth.currentUser.uid).get();

    if (!cart.exists) {
      await db.collection('carts').doc(auth.currentUser.uid).set({
        'products': [],
        'total': 0,
      });

      cart = await db.collection('carts').doc(auth.currentUser.uid).get();
    }

    List cartList = cart.get('products');
    var t = cartList.indexWhere((e) => e['product'] == productId);
   
    if (numItem > 1 || t != -1) {
      print('sds');
      return true;
    }

    List productsList = [];

    double total = 0;

    productsList.add({'numItem': 1, 'product': productId});

    if (auth.currentUser != null) {
      db.collection('carts').doc(auth.currentUser.uid).update({
        'products': productsList,
        'total': total,
      });
      return true;
    }
    return false;
  }

  calculateTotal() async {
    var cart = await db.collection('carts').doc(auth.currentUser.uid).get();

    if (!cart.exists) {
      await db.collection('carts').doc(auth.currentUser.uid).set({
        'products': [],
        'total': 0,
      });

      cart = await db.collection('carts').doc(auth.currentUser.uid).get();
    }

    List productsList = cart.get('products');

    double total = await sumItems(productsList, 0);

    await db.collection('carts').doc(auth.currentUser.uid).update({
      'total': total,
    });
  }

  Future<double> sumItems(List productsList, double total) async {
    await Future.forEach(productsList, (element) async {
      DocumentReference<Map<String, dynamic>> product = element['product'];
      var priceSnapShot = await product.get();

      var price = priceSnapShot.get('price');

      var val = price * element['numItem'];

      total = total + val;
    });
    return total;
  }

  removeFromCart(DocumentReference productId, int numItem, double totl,
      double price) async {
    var cart = await db.collection('carts').doc(auth.currentUser.uid).get();

    List productsList = [];

    productsList = cart?.data()['products'];

    productsList.removeWhere((element) => element['product'] == productId);

    var total = totl - (numItem * price);

    print(total);

    if (auth.currentUser != null) {
      db.collection('carts').doc(auth.currentUser.uid).update({
        'products': productsList,
        'total': total,
      });
    }
  }

  clearCart() {
    if (auth.currentUser != null) {
      db.collection('carts').doc(auth.currentUser.uid).update({
        'products': [],
        'total': 0,
      });
    }
  }

  placeOrder(Sales orders) async {
    await updateStock(orders);
    // print(orders.product[0]['product'].runtimeType);
    db.collection('orders').add({
      'products': orders.product,
      'order_date': orders.date,
      'buyerId': auth.currentUser.uid,
      'Status': orders.status,
      'total_price': orders.total,
    }).then((value) => clearCart(), onError: (e) {
      throw (e);
    });
  }

  Future updateStock(Sales orders) async {
    orders.product.forEach((element) async {
      DocumentReference<Map<String, dynamic>> product = element['product'];

      DocumentSnapshot<Map<String, dynamic>> r = await product.get();

      print(r);

      var stock = r.get('stock');

      product.update({
        'stock': stock - element['numItem'],
      });
    });
  }
}
