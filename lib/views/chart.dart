import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class Chart extends StatefulWidget {
  const Chart({
    super.key,
    required this.dataMap,
    required this.maxXValue,
    required this.maxYValue,
  });

  final Map<DateTime, dynamic> dataMap;
  final double maxXValue;
  final double maxYValue;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.25, // Dynamically adjust height
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
        ),
        child: LineChart(
          mainData(screenWidth),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double screenWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.02, // Slightly larger font for readability
    );

    DateTime date = widget.dataMap.keys.elementAt(value.toInt());
    String dateString;
    if (widget.maxXValue == 15) {
      dateString = DateFormat('MM/dd').format(date);
    } else if (widget.maxXValue == 6) {
      dateString = DateFormat('MMM yy').format(date);
    } else if (widget.maxXValue == 4) {
      dateString = DateFormat('MM/dd').format(date);
    } else {
      dateString = DateFormat('yyyy').format(date);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dateString, style: style),
    );
  }

  Widget leftTitleWidgets(dynamic value, TitleMeta meta, double screenWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.03,
    );

    return Text(
      value is int ? '$value' : '${value.ceil()}',
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData mainData(double screenWidth) {
    List<FlSpot> spots = [];
    List<DateTime> keys = widget.dataMap.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      DateTime date = keys[i];
      double value = (widget.dataMap[date] ?? 0.0) as double;
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    int numberOfDigits = widget.maxYValue.toString().split('.')[0].length;
    double reservedSize = 10.0 + (numberOfDigits * 5.0);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: widget.maxYValue > 0
            ? widget.maxYValue / 5
            : 1.0, // Limit horizontal grid lines
        drawVerticalLine: false,
      ),
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
            interval: widget.maxYValue > 0
                ? widget.maxYValue / 4
                : 1.0, // Limit vertical labels
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
      maxX: widget.maxXValue - 1,
      minY: 0,
      maxY: widget.maxYValue,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: screenWidth * 0.005,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
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
