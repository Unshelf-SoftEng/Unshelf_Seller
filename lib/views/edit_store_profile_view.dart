import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/viewmodels/store_profile_viewmodel.dart';

class EditStoreProfileView extends StatelessWidget {
  final StoreModel storeDetails;

  EditStoreProfileView({required this.storeDetails});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreProfileViewModel>(
      create: (_) => StoreProfileViewModel(storeDetails),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Store Profile'),
          backgroundColor: const Color(0xFF6A994E),
          foregroundColor: const Color(0xFFFFFFFF),
          titleTextStyle: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFF386641),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(
              color: Color(0xFFC8DD96),
              height: 4.0,
            ),
          ),
        ),
        body: Consumer<StoreProfileViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    child: ListView(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () => viewModel.pickImage(),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: viewModel.profileImage != null
                                  ? MemoryImage(viewModel.profileImage!)
                                  : storeDetails.storeImageUrl != null
                                      ? NetworkImage(
                                          storeDetails.storeImageUrl!)
                                      : null,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(Icons.camera_alt,
                                    color: Color(0xFFA7C957), size: 30),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: viewModel.nameController,
                          decoration: InputDecoration(labelText: 'Store Name'),
                        ),
                        SizedBox(height: 16.0),
                        Align(
                          alignment:
                              Alignment.center, // Center the ElevatedButton
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  const Color(0xFFA7C957)),
                              foregroundColor: WidgetStatePropertyAll(
                                  const Color(0xFF386641)),
                              alignment: Alignment.center,
                            ),
                            onPressed: viewModel.isLoading
                                ? null
                                : () async {
                                    await viewModel.updateStoreProfile();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Store Profile updated successfully!')),
                                    );
                                    Navigator.pop(context, true);
                                  },
                            child: Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
