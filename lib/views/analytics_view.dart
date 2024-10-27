import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/analytics_viewmodel.dart';
import 'package:unshelf_seller/views/chart.dart';

class AnalyticsView extends StatefulWidget {
  @override
  _AnalyticsViewState createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  String selectedSalesValue = 'Daily';
  String selectedOrdersValue = 'Daily';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsViewModel =
          Provider.of<AnalyticsViewModel>(context, listen: false);
      analyticsViewModel.fetchAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsViewModel = Provider.of<AnalyticsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF6A994E),
      ),
      body: analyticsViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lifetime Totals Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lifetime Totals',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Changed to black
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Centered Total Orders
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Total Orders',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${analyticsViewModel.totalOrders}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A994E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Order Status Breakdown in one row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Pending',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                      Text(
                                        '${analyticsViewModel.totalPendingOrders}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Ready',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                      Text(
                                        '${analyticsViewModel.totalReadyOrders}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                      Text(
                                        '${analyticsViewModel.totalCompletedOrders}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black, // Changed to black
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Centered Total Sales
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Total Sales',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱ ${analyticsViewModel.totalSales.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A994E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  DropdownButton<String>(
                    value: selectedOrdersValue,
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != selectedOrdersValue) {
                        setState(() {
                          selectedOrdersValue = newValue;
                        });
                        analyticsViewModel.getOrdersMap(newValue);
                      }
                    },
                    items: <String>['Daily', 'Weekly', 'Monthly', 'Annual']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  // Chart for orders
                  Chart(
                    dataMap: analyticsViewModel.ordersMap,
                    maxXValue: analyticsViewModel.maxXOrder,
                    maxYValue: analyticsViewModel.maxYOrder,
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Sales',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  DropdownButton<String>(
                    value: selectedSalesValue,
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != selectedSalesValue) {
                        setState(() {
                          selectedSalesValue = newValue;
                        });
                        analyticsViewModel.getSalesMap(newValue);
                      }
                    },
                    items: <String>['Daily', 'Weekly', 'Monthly', 'Annual']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  // Chart for sales
                  Chart(
                    dataMap: analyticsViewModel.salesMap, // Update as necessary
                    maxXValue: analyticsViewModel.maxXSales,
                    maxYValue: analyticsViewModel.maxYSales,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Top Popular Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10), // Spacing
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align items to the start
                      children: analyticsViewModel.topProducts
                          .map((product) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Space between name and orders
                                  children: [
                                    // Product Name and Image
                                    Row(
                                      children: [
                                        // Display Product Image
                                        Image.network(
                                          product['imageUrl'],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(
                                            width:
                                                10), // Spacing between image and name
                                        // Display Product Name
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Display Total Quantity Ordered
                                    Text(
                                      'Orders: ${product['totalQuantity']}', // Display total quantity ordered
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[
                                            600], // Grey text for order count
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20), // Additional spacing
                ],
              ),
            ),
    );
  }
}
