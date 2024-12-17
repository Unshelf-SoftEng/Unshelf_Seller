import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/dashboard_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
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
          return viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyAnalyticsCard(viewModel),
                      const SizedBox(height: 16.0),
                      _buildSaleSummaryCard(viewModel), // New Static Card
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildDailyAnalyticsCard(DashboardViewModel viewModel) {
    return Card(
      color: AppColors.primaryColor,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Today's Orders",
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
            const SizedBox(height: 12.0),
            _buildAnalyticsRow(
                'Processed', viewModel.processedOrders, Icons.cached),
            const SizedBox(height: 12.0),
            _buildAnalyticsRow(
                'Completed', viewModel.completedOrders, Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleSummaryCard(viewModel) {
    return Card(
      color: AppColors.primaryColor,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Store Insights",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
            ),
            Center(
                child: Text(viewModel.getCurrentMonth(),
                    style: TextStyle(fontSize: 12.0, color: Colors.white))),
            const SizedBox(height: 12.0),
            Center(
              child: _buildSummaryRow(
                  title: 'Total Sales',
                  value: '\u20B1  ${viewModel.totalSales}',
                  icon: Icons.sell),
            ),
            const SizedBox(height: 12.0),
            Center(
              child: _buildSummaryRow(
                  title: 'Inventory Remaining',
                  value: '${viewModel.totalStockRemaining} Products',
                  icon: Icons.inventory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the Row content
      children: [
        Icon(icon, color: Colors.white, size: 32.0),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: AppColors.saffronYellow,
                  fontFamily: 'Roboto'),
            ),
          ],
        ),
      ],
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
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.saffronYellow),
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.0,
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
}
