import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../providers/transaction_provider.dart';
import '../utils/date_utils.dart';

class MonthCategoryData {
  String month;
  String category;
  double value;

  MonthCategoryData(this.month, this.category, this.value);
}

class MonthlyCategoryData {
  String title;
  double value;
  Color color;

  MonthlyCategoryData(this.title, this.value, this.color);
}

class MonthlyCategoryChart extends StatefulWidget {
  const MonthlyCategoryChart({super.key});

  @override
  State<StatefulWidget> createState() => _MonthlyCategoryChartState();
}

class _MonthlyCategoryChartState extends State<MonthlyCategoryChart> {
  final String noFilter = "No filter";
  final int monthCount = 5;
  String _filter = ""; // either month or category
  final List<String> _filterItems = [];

  @override
  void initState() {
    super.initState();
    _filterItems.add(noFilter);
    for (int monthIndex in getLatestNmonthIndex(monthCount)) {
      _filterItems.add(Constant.monthLabels[monthIndex]);
    }
    _filterItems.addAll(Constant.expenseCategories);
    _filter = _filterItems[0];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<TransactionProvider>(
          builder: (context, transactionProvider, _) {
            final List<MonthCategoryData> pieData = transactionProvider.getMonthlyExpenseCategoryData(monthCount: monthCount);
            final List<MonthCategoryData> filteredData = pieData.where((MonthCategoryData element) {
              bool match = true;
              if (_filter != noFilter) {
                match = element.month.toLowerCase() == _filter.toLowerCase() ||
                        element.category.toLowerCase() == _filter.toLowerCase();
              }
              return match;
            }).toList();
            
            return SfCircularChart(
              title: ChartTitle(text: 'Monthly Expenses Category'),
              // Enable legend
              legend: Legend(
                isVisible: true,
                shouldAlwaysShowScrollbar: true,
                overflowMode: LegendItemOverflowMode.wrap,
                orientation: LegendItemOrientation.horizontal,
                itemPadding: 10,
              ),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <PieSeries<MonthlyCategoryData, String>>[
                PieSeries(
                  radius: Constant.isMobile(context) ? '90%' : '80%',
                  dataSource:getSections(filteredData),
                  xValueMapper: (MonthlyCategoryData record, _) => record.title,
                  yValueMapper: (MonthlyCategoryData record, _) => record.value,
                  pointColorMapper: (MonthlyCategoryData record, _) => record.color,
                  enableTooltip: true,
                )
              ],
            );
          },
        ),
        Text(
          'Filter Pie Chart by Month or Category ', 
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        DropdownButton<String>(
          value: _filter,
          icon: const Icon(Icons.filter_alt_outlined),
          iconSize: 22,
          elevation: 16,
          onChanged: (newValue) {
            setState(() {
              _filter = newValue!;
            });
          },
          items: _filterItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

List<MonthlyCategoryData> getSections(List<MonthCategoryData> pieData) {
  List<MonthlyCategoryData> sections = [];
  double total = pieData.fold(0, (sum, item) => sum + item.value);

  for (int i = 0; i < pieData.length; i++) {
    var item = pieData[i];
    sections.add(
      MonthlyCategoryData(
        '${item.month} ${item.category} ${(item.value / total * 100).toStringAsFixed(1)}%',
        double.parse(item.value.toStringAsFixed(2)),
        getColor(i)
      ),
    );
  }

  return sections;
}


  Color getColor(int index) {
    // If the index is out of range, return a random color
    if (index >= ColorConstant.chartColors.length) {
      return Color.fromRGBO(
        (53 + index * 53) % 255,
        (20 + index * 20) % 255,
        (80 + index * 80) % 255,
        1,
      );
    }

    // Otherwise, return the color at the specified index
    return ColorConstant.chartColors[index];
  }
}
