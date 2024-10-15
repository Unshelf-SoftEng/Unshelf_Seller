import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/dashboard_viewmodel.dart';
import 'package:unshelf_seller/views/analytics_view.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyAnalyticsCard(viewModel),
                const SizedBox(height: 16.0),
                _buildStoreInsightsCard(viewModel),
                const SizedBox(height: 16.0),
                _buildAnalyticsButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyAnalyticsCard(DashboardViewModel viewModel) {
    return Card(
      color: const Color(0xFF6A994E),
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Daily Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                'Date: ${viewModel.today.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildAnalyticsRow(
                'Pending', viewModel.pendingOrders, Icons.hourglass_empty),
            _buildAnalyticsRow(
                'Processed', viewModel.processedOrders, Icons.cached),
            _buildAnalyticsRow(
                'Completed', viewModel.completedOrders, Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInsightsCard(DashboardViewModel viewModel) {
    return Card(
      color: const Color(0xFF6A994E),
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: Text('Store Insights',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30.0))),
            const SizedBox(height: 5.0),
            Center(
                child: Text(
                    'An overview of the shop data for ${viewModel.monthYear}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ))),
            const SizedBox(height: 16.0),
            _buildInsightsRow('Total Orders', '${viewModel.totalOrders}',
                Icons.shopping_cart),
            const SizedBox(height: 16.0),
            _buildInsightsRow(
                'Total Sales',
                '${viewModel.totalSales.toStringAsFixed(2)} Php',
                Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String title, int value, IconData icon) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 32.0),
            ],
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFDC5F)),
                ),
              ),
              const SizedBox(height: 4.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsRow(String title, String value, IconData icon) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const textStyleValue = TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFDC5F),
          );

          const textStyleTitle = TextStyle(
            fontSize: 14.0,
            color: Colors.white,
          );

          // Measure the width of the longest text
          final valueText = Text(
                value,
                style: textStyleValue,
              ).data?.length ??
              0;

          final titleText = Text(
                title,
                style: textStyleTitle,
              ).data?.length ??
              0;

          final maxTextWidth = valueText > titleText ? valueText : titleText;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 32.0),
                ],
              ),
              const SizedBox(width: 16.0),
              // Text Column with fixed width
              Container(
                constraints: BoxConstraints(
                  maxWidth:
                      maxTextWidth * 8.0, // Estimate width based on text length
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: textStyleValue,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      title,
                      style: textStyleTitle,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AnalyticsView()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF6A994E), // Use the same color as the cards
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        child: const Text('View Analytics'),
      ),
    );
  }
}
