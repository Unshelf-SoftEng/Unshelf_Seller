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
                const SizedBox(height: 24.0), // Increased spacing
                _buildStoreInsightsCard(viewModel),
                const SizedBox(height: 24.0), // Increased spacing
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
      elevation: 8.0, // Increased elevation
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
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildAnalyticsRow(
                'Pending', viewModel.pendingOrders, Icons.hourglass_empty),
            const SizedBox(height: 12.0), // More space between rows
            _buildAnalyticsRow(
                'Processed', viewModel.processedOrders, Icons.cached),
            const SizedBox(height: 12.0), // More space between rows
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
      elevation: 8.0, // Increased elevation
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
                      fontSize: 30.0)),
            ),
            const SizedBox(height: 8.0), // Increased space
            Center(
              child: Text(
                'An overview of the shop data for ${viewModel.monthYear}',
                style: const TextStyle(color: Colors.white, fontSize: 12.0),
              ),
            ),
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
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFDC5F),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsButton() {
    return Center(
      child: ElevatedButton.icon(
        // Added icon to button
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AnalyticsView()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A994E), // Same color as the cards
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        icon: const Icon(Icons.bar_chart), // Added an icon
        label: const Text('View Analytics'),
      ),
    );
  }
}
