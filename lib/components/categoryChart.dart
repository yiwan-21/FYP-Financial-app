import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryChart extends StatefulWidget {
  const CategoryChart({Key? key}) : super(key: key);

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: PieChart(
        PieChartData(
          sections: getSections(),
          centerSpaceRadius: 40,
          sectionsSpace: 0,
          borderData: FlBorderData(
            show: false,
          ),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (response != null) {
                  touchedIndex = response.touchedSection!.touchedSectionIndex;
                } else {
                  touchedIndex = -1;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    return [
      PieChartSectionData(
        value: 20,
        color: Colors.green,
        title: '20%',
        radius: touchedIndex == 0 ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: touchedIndex == 0 ? Colors.white : Colors.black,
        ),
      ),
      PieChartSectionData(
        value: 30,
        color: Colors.lightBlue,
        title: '30%',
        radius: touchedIndex == 1 ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: touchedIndex == 1 ? Colors.white : Colors.black,
        ),
      ),
      PieChartSectionData(
        value: 50,
        color: Colors.orange,
        title: '50%',
        radius: touchedIndex == 2 ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: touchedIndex == 2 ? Colors.white : Colors.black,
        ),
      ),
    ];
  }
}
