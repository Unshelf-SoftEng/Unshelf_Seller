import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/views/image_delete_view.dart';
import 'package:unshelf_seller/views/bundle_suggestions_view.dart';

class EditBundleView extends StatefulWidget {
  final String bundleId;

  EditBundleView({required this.bundleId});

  @override
  _EditBundleViewState createState() => _EditBundleViewState();
}

class _EditBundleViewState extends State<EditBundleView> {
  late BundleViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<BundleViewModel>();
    viewModel.getBundleDetails(widget.bundleId);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BundleViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bundle'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew), // Icon for AI suggestions
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BundleSuggestionsView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final String mainImageUrl;
  final String productId;
  final String name;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  _ProductListTile({
    required this.mainImageUrl,
    required this.productId,
    required this.name,
    required this.price,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Add margin to each tile
      elevation: 2.0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Image.network(
          mainImageUrl,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.green : Colors.black,
          ),
        ),
        subtitle: Text('Price: $price'),
        tileColor:
            isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
