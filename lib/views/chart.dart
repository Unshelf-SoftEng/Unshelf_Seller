import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chart extends StatefulWidget {
  const Chart({super.key, required this.dataMap});

  final Map<String, dynamic> dataMap;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Color> gradientColors = [
    Colors.greenAccent,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final height = screenHeight * 0.5;

    return SizedBox(
      height: height < 300 ? 300 : height,
      child: Padding(
        padding: EdgeInsets.only(
          right: screenWidth * 0.05, // 5% of screen width
          left: screenWidth * 0.03, // 3% of screen width
          top: screenHeight * 0.05, // 5% of screen height
          bottom: screenHeight * 0.02, // 2% of screen height
        ),
        child: LineChart(
          mainData(screenWidth), // Pass the screen width to adjust titles
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double screenWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.0075, // Dynamic font size
    );

    String dateString = DateFormat('MM/dd')
        .format(DateTime.now().subtract(Duration(days: 29 - value.toInt())));
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dateString, style: style),
    );
  }

  Widget leftTitleWidgets(dynamic value, TitleMeta meta, double screenWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.0075,
    );

    return Text(
      value is int ? '$value' : '${value.toStringAsFixed(0)}',
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData mainData(double screenWidth) {
    List<FlSpot> spots = [];

    for (int i = 0; i < 30; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: 29 - i));
      String formattedDate = DateFormat('MM/dd').format(date);
      double ordersCount = (widget.dataMap[formattedDate] ?? 0.0) as double;
      spots.add(FlSpot(i.toDouble(), ordersCount.toDouble()));
    }

    final maxYValue = widget.dataMap.values
        .where((value) => value is num)
        .map((value) => value is int ? value.toDouble() : value)
        .reduce((a, b) => a > b ? a : b);

    // Calculate reserved size based on number of digits in maxYValue
    int numberOfDigits = maxYValue
        .toString()
        .split('.')[0]
        .length; // Count digits before decimal
    double reservedSize = 10.0 +
        (numberOfDigits * 5.0); // Adjust the multiplier as neededint number of

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(value, meta, screenWidth),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 300,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(value, meta, screenWidth),
            reservedSize: reservedSize,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 29,
      minY: 0,
      maxY: maxYValue + 1,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: screenWidth * 0.01, // Dynamic bar width
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
