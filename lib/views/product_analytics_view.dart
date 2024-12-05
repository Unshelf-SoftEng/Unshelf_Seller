import 'package:flutter/material.dart';
import 'package:unshelf_seller/views/chart.dart';
import 'package:intl/intl.dart';

class ProductAnalyticsView extends StatefulWidget {
  @override
  _ProductAnalyticsViewState createState() => _ProductAnalyticsViewState();
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

// Function to generate a list of DateTimes for the past N days
    List<DateTime> generateDateRange(int days) {
      return List.generate(days, (index) {
        return today.subtract(Duration(days: index));
      });
    }

// Function to generate a list of DateTimes for the past N weeks
    List<DateTime> generateWeekRange(int weeks) {
      return List.generate(weeks, (index) {
        return today.subtract(Duration(days: (index * 7)));
      });
    }

// Function to generate a list of DateTimes for the past N months
    List<DateTime> generateMonthRange(int months) {
      return List.generate(months, (index) {
        return DateTime(today.year, today.month - index, today.day);
      });
    }

// Function to generate a list of DateTimes for the past N years
    List<DateTime> generateYearRange(int years) {
      return List.generate(years, (index) {
        return DateTime(today.year - index, today.month, today.day);
      });
    }

// Helper function to generate a reasonable daily order count
    int generateDailyOrders(int baseOrders) {
      return (baseOrders +
              (baseOrders *
                  0.2 *
                  (2 * (0.5 - DateTime.now().millisecondsSinceEpoch % 1000))))
          .toInt();
    }

    data = {
      'Apple': {
        'totalOrders': 1200,
        'totalSales': 30000.0,
        'totalPendingOrders': 100,
        'totalReadyOrders': 400,
        'totalCompletedOrders': 700,
        'dailyOrdersMap': generateDateRange(15).asMap().map((index, date) {
          int dailyOrders = generateDailyOrders(80);
          return MapEntry(date, dailyOrders);
        }),
        'weeklyOrdersMap': generateWeekRange(4).asMap().map((index, date) {
          int weeklyOrders = (index + 1) * 200;
          return MapEntry(date, weeklyOrders);
        }),
        'monthlyOrdersMap': generateMonthRange(6).asMap().map((index, date) {
          int monthlyOrders = (index + 1) * 400;
          return MapEntry(date, monthlyOrders);
        }),
        'annualOrdersMap': generateYearRange(3).asMap().map((index, date) {
          int annualOrders = (index + 1) * 800;
          return MapEntry(date, annualOrders);
        }),
        'dailySalesMap': generateDateRange(15).asMap().map((index, date) {
          double dailySales = (generateDailyOrders(80) * 2.5);
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = (index + 1) * 500.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = (index + 1) * 1200.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = (index + 1) * 2500.0;
          return MapEntry(date, annualSales);
        }),
      },
      'Watermelon': {
        'totalOrders': 800,
        'totalSales': 16000.0,
        'totalPendingOrders': 100,
        'totalReadyOrders': 300,
        'totalCompletedOrders': 400,
        'dailyOrdersMap': generateDateRange(15).asMap().map((index, date) {
          int dailyOrders = generateDailyOrders(50);
          return MapEntry(date, dailyOrders);
        }),
        'weeklyOrdersMap': generateWeekRange(4).asMap().map((index, date) {
          int weeklyOrders = (index + 1) * 150;
          return MapEntry(date, weeklyOrders);
        }),
        'monthlyOrdersMap': generateMonthRange(6).asMap().map((index, date) {
          int monthlyOrders = (index + 1) * 300;
          return MapEntry(date, monthlyOrders);
        }),
        'annualOrdersMap': generateYearRange(3).asMap().map((index, date) {
          int annualOrders = (index + 1) * 600;
          return MapEntry(DateFormat('yyyy').format(date), annualOrders);
        }),
        'dailySalesMap': generateDateRange(15).asMap().map((index, date) {
          double dailySales = (generateDailyOrders(50) * 2.0);
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = (index + 1) * 400.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = (index + 1) * 900.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = (index + 1) * 1800.0;
          return MapEntry(DateFormat('yyyy').format(date), annualSales);
        }),
      },
      'Purple Grapes': {
        'totalOrders': 1500,
        'totalSales': 37500.0,
        'totalPendingOrders': 150,
        'totalReadyOrders': 700,
        'totalCompletedOrders': 650,
        'dailyOrdersMap': generateDateRange(15).asMap().map((index, date) {
          int dailyOrders = generateDailyOrders(
              100); // Adjust daily orders based on the total
          return MapEntry(date, dailyOrders);
        }),
        'weeklyOrdersMap': generateWeekRange(4).asMap().map((index, date) {
          int weeklyOrders =
              (index + 1) * 350; // Weekly orders consistent with daily data
          return MapEntry(date, weeklyOrders);
        }),
        'monthlyOrdersMap': generateMonthRange(6).asMap().map((index, date) {
          int monthlyOrders = (index + 1) * 700;
          return MapEntry(date, monthlyOrders);
        }),
        'annualOrdersMap': generateYearRange(3).asMap().map((index, date) {
          int annualOrders = (index + 1) * 1400;
          return MapEntry(DateFormat('yyyy').format(date), annualOrders);
        }),
        'dailySalesMap': generateDateRange(15).asMap().map((index, date) {
          double dailySales = (generateDailyOrders(100) *
              2.5); // Adjust sales based on daily orders
          return MapEntry(date, dailySales);
        }),
        'weeklySalesMap': generateWeekRange(4).asMap().map((index, date) {
          double weeklySales = (index + 1) * 1000.0;
          return MapEntry(date, weeklySales);
        }),
        'monthlySalesMap': generateMonthRange(6).asMap().map((index, date) {
          double monthlySales = (index + 1) * 2500.0;
          return MapEntry(date, monthlySales);
        }),
        'annualSalesMap': generateYearRange(3).asMap().map((index, date) {
          double annualSales = (index + 1) * 5000.0;
          return MapEntry(date, annualSales);
        }),
      },
    };
  }

  // Function to generate a list of DateTimes for the past N days
  List<DateTime> generateDateRange(int days) {
    return List.generate(days, (index) {
      return today.subtract(Duration(days: index));
    });
  }

// Function to generate a list of DateTimes for the past N weeks
  List<DateTime> generateWeekRange(int weeks) {
    return List.generate(weeks, (index) {
      return today.subtract(Duration(days: (index * 7)));
    });
  }

// Function to generate a list of DateTimes for the past N months
  List<DateTime> generateMonthRange(int months) {
    return List.generate(months, (index) {
      return DateTime(today.year, today.month - index, today.day);
    });
  }

// Function to generate a list of DateTimes for the past N years
  List<DateTime> generateYearRange(int years) {
    return List.generate(years, (index) {
      return DateTime(today.year - index, today.month, today.day);
    });
  }

// Helper function to generate a reasonable daily order count
  int generateDailyOrders(int baseOrders) {
    return (baseOrders +
            (baseOrders *
                0.2 *
                (2 * (0.5 - DateTime.now().millisecondsSinceEpoch % 1000))))
        .toInt();
  }

  Map<String, dynamic> get currentProductData {
    return data[selectedProduct]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Analytics'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Dropdown
            const Text(
              'Select Product',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
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
                  child: Text(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
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
                          '${currentProductData['totalOrders']}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A994E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Order Status Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${currentProductData['totalPendingOrders']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${currentProductData['totalReadyOrders']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${currentProductData['totalCompletedOrders']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                          '₱ ${currentProductData['totalSales'].toStringAsFixed(2)}',
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

            // Sales and Orders Chart
            Text(
              'Sales Overview (${selectedSalesValue})',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),

            // Chart for the selected sales view
            if (selectedSalesValue == 'Daily')
              Chart(
                dataMap: currentProductData['dailySalesMap'],
                maxXValue: 3,
                maxYValue: currentProductData['dailySalesMap'].values.reduce(
                    (value, element) => value > element ? value : element),
              )
            else if (selectedSalesValue == 'Weekly')
              Chart(
                dataMap: currentProductData['weeklySalesMap'],
                maxXValue: 4,
                maxYValue: currentProductData['weeklySalesMap'].values.reduce(
                    (value, element) => value > element ? value : element),
              )
            else if (selectedSalesValue == 'Monthly')
              Chart(
                dataMap: currentProductData['monthlySalesMap'],
                maxXValue: 12,
                maxYValue: currentProductData['monthlySalesMap'].values.reduce(
                    (value, element) => value > element ? value : element),
              )
            else
              Chart(
                dataMap: currentProductData['annualSalesMap'],
                maxXValue: 3,
                maxYValue: currentProductData['annualSalesMap'].values.reduce(
                    (value, element) => value > element ? value : element),
              ),
          ],
        ),
      ),
    );
  }
}
