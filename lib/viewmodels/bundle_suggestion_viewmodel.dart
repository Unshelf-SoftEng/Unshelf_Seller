import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class BundleSuggestionViewModel extends ChangeNotifier {
  List<BundleModel> _suggestions = [];
  List<BundleModel> get suggestions => _suggestions;

  List<BatchModel> _products = [];
  List<BatchModel> get products => _products;

  final BatchService _batchService = BatchService();

  Future<void> fetchSuggestions() async {
    const url = 'https://productbundlerapi.onrender.com/api/recommend-bundles/';

    final headers = {'Content-Type': 'application/json'};

    // Modify this to get all the batches, then create a JSON object from the list
    // _products = await _();

    // final body = json.encode(
    //   _products.map((product) => product.toJson()).toList(),
    // );

    // try {
    //   final response =
    //       await http.post(Uri.parse(url), headers: headers, body: body);

    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);
    //     print('Suggestions: $data');

    //     _suggestions = (data['bundles'] as List)
    //         .map<BundleModel>((bundle) => BundleModel.fromJson(bundle))
    //         .toList();

    //     for (var suggestion in _suggestions) print(suggestion.name);

    //     notifyListeners();
    //   } else {
    //     print('Error: ${response.reasonPhrase}');
    //   }
    // } catch (e) {
    //   print('Exception: $e');
    // }
  }
}
