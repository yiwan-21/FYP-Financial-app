import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../providers/total_transaction_provider.dart';

class CategoryData {
  String title;
  double value;
  Color color;

  CategoryData(this.title, this.value, this.color);
}

class CategoryChart extends StatefulWidget {
  const CategoryChart({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TotalTransactionProvider>(
      builder: (context, totalTransactionProvider, _) {
        if (totalTransactionProvider.getPieChartData.isNotEmpty) {
          return SfCircularChart(
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <PieSeries<CategoryData, String>>[
              PieSeries(
                radius: Constant.isMobile(context) ? '70%' : '80%',
                dataSource:
                    getSections(totalTransactionProvider.getPieChartData),
                xValueMapper: (CategoryData record, _) => record.title,
                yValueMapper: (CategoryData record, _) => record.value,
                pointColorMapper: (CategoryData record, _) => record.color,
                enableTooltip: true,
              )
            ],
          );
        } else {
           return Container();
        }
      },
    );
  }

  List<CategoryData> getSections(objData) {
    List<CategoryData> sections = [];
    final values = objData.values.toList();
    for (int i = 0; i < objData.length; i++) {
      sections.add(
        CategoryData(
          '${objData.keys.toList()[i]} ${(values[i] / values.reduce((double a, double b) => a + b) * 100).toStringAsFixed(1)}%',
          values[i],
          getColor(i),
        ),
      );
    }

    return sections;
  }

  Color getColor(int index) {
    // If the index is out of range, return a random color
    if (index >= ColorConstant.chartColors.length) {
      return Color.fromRGBO(
        100 + index * 10,
        50 + index * 5,
        150 + index * 15,
        1,
      );
    }

    // Otherwise, return the color at the specified index
    return ColorConstant.chartColors[index];
  }
}
