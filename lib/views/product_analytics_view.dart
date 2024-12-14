import 'dart:math';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/components/chart.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';

class ProductAnalyticsView extends StatefulWidget {
  const ProductAnalyticsView({super.key});

  @override
  State<ProductAnalyticsView> createState() => _ProductAnalyticsViewState();
}

class _ProductAnalyticsViewState extends State<ProductAnalyticsView> {
  String selectedSalesValue = 'Daily';
  String selectedOrdersValue = 'Daily';
  String selectedProduct = 'Apple';
  Map<String, Map<String, dynamic>> data = {};

  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();

    List<DateTime> generateDateRange(int days) {
      return List.generate(days, (index) {
        return today.subtract(Duration(days: index));
      });
    }

    List<DateTime> generateWeekRange(int weeks) {
      return List.generate(weeks, (index) {
        return today.subtract(Duration(days: (index * 7)));
      });
    }

    List<DateTime> generateMonthRange(int months) {
      return List.generate(months, (index) {
        return DateTime(today.year, today.month - index, today.day);
      });
    }

    List<DateTime> generateYearRange(int years) {
      return List.generate(years, (index) {
        return DateTime(today.year - index, today.month, today.day);
      });
    }

    int generateDailyOrders(int baseOrders) {
      return (baseOrders +
              (baseOrders *
                  0.2 *
                  (2 * (0.5 - DateTime.now().millisecondsSinceEpoch % 1000))))
          .toInt();
    }

    data = {
      'Apple': {
        'totalOrders': 200,
        'totalSales': 36000.0,
        'totalCancelledOrders': 20,
        'totalCompletedOrders': 180,
        'dailySalesMap': generateDateRange(14).asMap().map((index, date) {
          double dailySales = Random().nextDouble() * 100.0;
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = Random().nextDouble() * 500.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = Random().nextDouble() * 1000.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = Random().nextDouble() * 10000.0;
          return MapEntry(date, annualSales);
        }),
      },
      'Watermelon': {
        'totalOrders': 50,
        'totalSales': 12250.0,
        'totalCompletedOrders': 49,
        'totalCancelledOrders': 1,
        'dailySalesMap': generateDateRange(14).asMap().map((index, date) {
          double dailySales = Random().nextDouble() * 200.0;
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = Random().nextDouble() * 1000.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = Random().nextDouble() * 2000.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = Random().nextDouble() * 10000.0;
          return MapEntry(date, annualSales);
        }),
      },
      'Purple Grapes': {
        'totalOrders': 100,
        'totalSales': 19000.0,
        'totalCompletedOrders': 95,
        'totalCancelledOrders': 5,
        'dailySalesMap': generateDateRange(14).asMap().map((index, date) {
          double dailySales = Random().nextDouble() * 100.0;
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = Random().nextDouble() * 500.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = Random().nextDouble() * 1200.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = Random().nextDouble() * 2500.0;
          return MapEntry(date, annualSales);
        }),
      },
    };
  }

  Map<String, dynamic> get currentProductData {
    return data[selectedProduct]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Product Analytics',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Dropdown
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProduct,
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != selectedProduct) {
                      setState(() {
                        selectedProduct = newValue;
                      });
                    }
                  },
                  items: <String>['Apple', 'Watermelon', 'Purple Grapes']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lifetime Totals Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lifetime Totals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Total Orders',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentProductData['totalOrders']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A994E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('Completed',
                                  currentProductData['totalCompletedOrders']),
                              _buildStatColumn('Cancelled',
                                  currentProductData['totalCancelledOrders']),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Total Sales',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱ ${currentProductData['totalSales'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
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
            ),

            const SizedBox(height: 20),

            // Sales Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Overview ($selectedSalesValue)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSalesValue,
                    items: ['Daily', 'Weekly', 'Monthly', 'Annual']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSalesValue = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            _buildChart(selectedSalesValue, currentProductData),
          ],
        ),
      ),
    );
  }
}

// Helper Method for Max Y-Value
double _getMaxY(Map<DateTime, double> dataMap) {
  return dataMap.values.isNotEmpty
      ? dataMap.values.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b)
      : 0.0;
}

// Helper Method for Chart
Widget _buildChart(String selectedValue, Map<String, dynamic> data) {
  switch (selectedValue) {
    case 'Daily':
      return Chart(
          dataMap: data['dailySalesMap'],
          maxXValue: 14,
          maxYValue: _getMaxY(data['dailySalesMap']));
    case 'Weekly':
      return Chart(
          dataMap: data['weeklySalesMap'],
          maxXValue: 4,
          maxYValue: _getMaxY(data['weeklySalesMap']));
    case 'Monthly':
      return Chart(
          dataMap: data['monthlySalesMap'],
          maxXValue: 6,
          maxYValue: _getMaxY(data['monthlySalesMap']));
    default:
      return Chart(
          dataMap: data['annualSalesMap'],
          maxXValue: 3,
          maxYValue: _getMaxY(data['annualSalesMap']));
  }
}

// Helper Method for Stats
Widget _buildStatColumn(String title, int value) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 2),
      Text(
        '$value',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
