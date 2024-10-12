import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

enum CartStatus {
  loading,
  error,
  exists,
  notExists,
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String selectedSize = 'M';
  String selectedColor = 'Black';

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Black', 'White', 'Red'];

  CartStatus cartStatus = CartStatus.notExists;

  void shareProduct() {
    final shareText = 'Check out this product: ${widget.product.name}\n'
        'Description: ${widget.product.description}\n'
        'Price: \$${widget.product.price}\n';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final DocumentReference cartRef =
        FirebaseFirestore.instance.collection('cart').doc(widget.product.id);
    final Stream<List<Product>> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('maincateg', isEqualTo: widget.product.category)
        .where('subcateg', isEqualTo: widget.product.subcateg)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 16.0),
            _buildProductDetails(cartRef),
            const Divider(thickness: 1),
            const SizedBox(height: 16.0),
            _buildRecommendedProducts(productsStream),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
          imageUrl: widget.product.images[0],
          height: 350,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }

  Widget _buildProductDetails(DocumentReference cartRef) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTitleAndPrice(),
          const SizedBox(height: 10),
          _buildSizeAndColorDropdowns(),
          const SizedBox(height: 10),
          Text(widget.product.description,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildAddToCartButton(cartRef),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Row _buildProductTitleAndPrice() {
    final double discountPrice =
        widget.product.price * (1 - (widget.product.discount / 100));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(widget.product.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.product.discount > 0)
              Text('\$${discountPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
            Text('\$${widget.product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Row _buildSizeAndColorDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdown<String>('Size', sizes, selectedSize, (value) {
          setState(() {
            selectedSize = value!;
          });
        }),
        _buildDropdown<String>('Color', colors, selectedColor, (value) {
          setState(() {
            selectedColor = value!;
          });
        }),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ],
    );
  }

  DropdownButton<String> _buildDropdown<T>(
    String hint,
    List<String> items,
    String selectedItem,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: selectedItem,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              color: value == selectedItem ? Colors.blue : Colors.black,
              fontWeight:
                  value == selectedItem ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddToCartButton(DocumentReference cartRef) {
    return StreamBuilder<DocumentSnapshot>(
      stream: cartRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        if (!snapshot.data!.exists) {
          return _buildAddToCartButtonUI();
        } else {
          return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {},
                child: const Text("Already in Cart",
                    style: TextStyle(color: Colors.white)),
              ));
        }
      },
    );
  }

  Widget _buildAddToCartButtonUI() {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {
            setState(() {
              cartStatus = CartStatus.loading;
            });

            try {
              await FirebaseFirestore.instance
                  .collection('cart')
                  .doc(widget.product.id)
                  .set({
                'proname': widget.product.name,
                'proprice': widget.product.price,
                'prosize': selectedSize,
                'procolor': selectedColor,
                'proimage': widget.product.images[0],
                'userid': FirebaseAuth.instance.currentUser!.uid,
                'existInCart': true,
                'cartProId': widget.product.id,
                'quantity': 1,
              });
              setState(() {
                cartStatus = CartStatus.exists;
              });
            } catch (e) {
              setState(() {
                cartStatus = CartStatus.error;
              });
            }
          },
          child: cartStatus == CartStatus.loading
              ? const CircularProgressIndicator()
              : const Text('ADD TO CART',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      );
    });
  }

  Widget _buildRecommendedProducts(Stream<List<Product>> productsStream) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You may also like',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: StreamBuilder<List<Product>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching products'));
                }

                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildRecommendedProductCard(products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductCard(Product product) {
    final double discountPrice = product.price * (1 - (product.discount / 100));
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.images[0],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 50),
              ),
            ),
            const SizedBox(height: 5),
            Text(product.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (product.discount > 0)
              Text('\$${discountPrice.toStringAsFixed(2)}',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 14)),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
