import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/analytics_viewmodel.dart';
import 'package:unshelf_seller/components/chart.dart';
import 'package:unshelf_seller/utils/colors.dart';

class StoreAnalyticsView extends StatefulWidget {
  const StoreAnalyticsView({super.key});

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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Store Analytics',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, analyticsViewModel, _) {
          return analyticsViewModel.isLoading
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
                                color: Colors.black,
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
                                              color: Colors
                                                  .black, // Changed to black
                                            ),
                                          ),
                                          Text(
                                            '${analyticsViewModel.totalPendingOrders}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .black, // Changed to black
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
                                              color: Colors
                                                  .black, // Changed to black
                                            ),
                                          ),
                                          Text(
                                            '${analyticsViewModel.totalReadyOrders}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .black, // Changed to black
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
                                              color: Colors
                                                  .black, // Changed to black
                                            ),
                                          ),
                                          Text(
                                            '${analyticsViewModel.totalCompletedOrders}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .black, // Changed to black
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
                                    '\u20B1 ${analyticsViewModel.totalSales.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily:
                                          'Roboto', // Set font to Roboto
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          0xFF6A994E), // Green color for sales
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      DropdownButton<String>(
                        value: selectedOrdersValue,
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              newValue != selectedOrdersValue) {
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

                      if (selectedOrdersValue == 'Daily' &&
                          analyticsViewModel.dailyOrdersMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.dailyOrdersMap,
                          maxXValue: 14,
                          maxYValue: analyticsViewModel.dailyMaxYOrder,
                        )
                      else if (selectedOrdersValue == 'Weekly' &&
                          analyticsViewModel.weeklyOrdersMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.weeklyOrdersMap,
                          maxXValue: 4,
                          maxYValue: analyticsViewModel.weeklyMaxYOrder,
                        )
                      else if (selectedOrdersValue == 'Monthly' &&
                          analyticsViewModel.monthlyOrdersMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.monthlyOrdersMap,
                          maxXValue: 6,
                          maxYValue: analyticsViewModel.monthlyMaxYOrder,
                        )
                      else if (selectedOrdersValue == 'Annual' &&
                          analyticsViewModel.annualOrdersMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.annualOrdersMap,
                          maxXValue: 3,
                          maxYValue: analyticsViewModel.annualMaxYOrder,
                        ),

                      const SizedBox(height: 30),
                      const Text(
                        'Sales',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      DropdownButton<String>(
                        value: selectedSalesValue,
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              newValue != selectedSalesValue) {
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

                      if (selectedSalesValue == 'Daily' &&
                          analyticsViewModel.dailySalesMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.dailySalesMap,
                          maxXValue: 14,
                          maxYValue: analyticsViewModel.dailyMaxYSales,
                        )
                      else if (selectedSalesValue == 'Weekly' &&
                          analyticsViewModel.weeklySalesMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.weeklySalesMap,
                          maxXValue: 4,
                          maxYValue: analyticsViewModel.weeklyMaxYSales,
                        )
                      else if (selectedSalesValue == 'Monthly' &&
                          analyticsViewModel.monthlySalesMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.monthlySalesMap,
                          maxXValue: 6,
                          maxYValue: analyticsViewModel.monthlyMaxYSales,
                        )
                      else if (selectedSalesValue == 'Annual' &&
                          analyticsViewModel.annualSalesMap.isNotEmpty)
                        Chart(
                          dataMap: analyticsViewModel.annualSalesMap,
                          maxXValue: 3,
                          maxYValue: analyticsViewModel.annualMaxYSales,
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
