import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/add_product_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('products')
                .where('seller_id', isEqualTo: user.uid)
                .snapshots()
            : Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              final productName = product['name'] ?? 'Unnamed Product';
              final productPrice = product['price'] ?? 0.0;

              return ListTile(
                leading: CachedNetworkImage(
                  // Use CachedNetworkImage
                  imageUrl: product['image_url'] ??
                      '', // Provide default empty string
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, size: 50),
                ),
                title: Text(productName),
                subtitle: Text('₱ ${productPrice.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Add this line
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductView(
                              productId: products[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(productId)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddProductView(
                      productId: null,
                    )),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
