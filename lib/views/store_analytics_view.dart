import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/analytics_viewmodel.dart';
import 'package:unshelf_seller/views/chart.dart';
import 'package:unshelf_seller/views/product_analytics_view.dart';

class StoreAnalyticsView extends StatefulWidget {
  @override
  State<StoreAnalyticsView> createState() => _StoreAnalyticsViewState();
}

class _StoreAnalyticsViewState extends State<StoreAnalyticsView> {
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
        title: Text('Store Analytics'),
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
                              const Text(
                                'Total Sales',
                                style: TextStyle(
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

                  if (selectedOrdersValue == 'Daily')
                    Chart(
                      dataMap: analyticsViewModel.dailyOrdersMap,
                      maxXValue: 14,
                      maxYValue: analyticsViewModel.dailyMaxYOrder,
                    )
                  else if (selectedOrdersValue == 'Weekly')
                    Chart(
                      dataMap: analyticsViewModel.weeklyOrdersMap,
                      maxXValue: 4,
                      maxYValue: analyticsViewModel.weeklyMaxYOrder,
                    )
                  else if (selectedOrdersValue == 'Monthly')
                    Chart(
                      dataMap: analyticsViewModel.monthlyOrdersMap,
                      maxXValue: 6,
                      maxYValue: analyticsViewModel.monthlyMaxYOrder,
                    )
                  else
                    Chart(
                      dataMap: analyticsViewModel.annualOrdersMap,
                      maxXValue: 3,
                      maxYValue: analyticsViewModel.annualMaxYOrder,
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

                  if (selectedSalesValue == 'Daily')
                    Chart(
                      dataMap: analyticsViewModel.dailySalesMap,
                      maxXValue: 14,
                      maxYValue: analyticsViewModel.dailyMaxYSales,
                    )
                  else if (selectedSalesValue == 'Weekly')
                    Chart(
                      dataMap: analyticsViewModel.weeklySalesMap,
                      maxXValue: 4,
                      maxYValue: analyticsViewModel.weeklyMaxYSales,
                    )
                  else if (selectedSalesValue == 'Monthly')
                    Chart(
                      dataMap: analyticsViewModel.monthlySalesMap,
                      maxXValue: 6,
                      maxYValue: analyticsViewModel.monthlyMaxYSales,
                    )
                  else
                    Chart(
                      dataMap: analyticsViewModel.annualSalesMap,
                      maxXValue: 3,
                      maxYValue: analyticsViewModel.annualMaxYSales,
                    ),
                ],
              ),
            ),
    );
  }
}
