import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../providers/total_transaction_provider.dart';

class CategoryChart extends StatefulWidget {
  const CategoryChart({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<TotalTransactionProvider>(
      builder: (context, totalTransactionProvider, _) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Constant.isMobile(context) ? double.infinity : 768,
            maxHeight: Constant.isMobile(context) ? 300 : double.infinity,
          ),
          child: Flex(
            direction: Constant.isMobile(context)
                ? Axis.vertical
                : Axis.horizontal,
            children: [
              Flexible(
                flex: Constant.isMobile(context) ? 2 : 1,
                child: SizedBox(
                  height: Constant.isMobile(context) ? 200 : 220,
                  child: PieChart(
                    PieChartData(
                      sections: getSections(totalTransactionProvider.getPieChartData),
                      centerSpaceRadius:
                          Constant.isMobile(context) ? 40 : 50,
                      sectionsSpace: 0,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (response != null) {
                              touchedIndex = response
                                  .touchedSection!.touchedSectionIndex;
                            } else {
                              touchedIndex = -1;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                // flex: Constant.isMobile(context) ? 1 : 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: getLegend(totalTransactionProvider.getPieChartData.keys.toList())),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> getSections(objData) {
    List<PieChartSectionData> sections = [];
    final values = objData.values.toList();
    for (int i = 0; i < objData.length; i++) {
      sections.add(
        PieChartSectionData(
          value: values[i],
          color: getColor(i),
          title:
              '${(values[i] / values.reduce((double a, double b) => a + b) * 100).toStringAsFixed(1)}%',
          radius: touchedIndex == i ? 60 : 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: touchedIndex == i ? Colors.white : Colors.black,
          ),
          // tooltip message
          badgeWidget: touchedIndex == i
              ? Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${objData.keys.toList()[i]}: ${values[i].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
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

  List<Widget> getLegend(categories) {
    List<Widget> legend = [];

    int numRows = (categories.length / 2).ceil();

    for (int i = 0; i < numRows; i++) {
      List<Widget> rowChildren = [];

      for (int j = 0; j < 2; j++) {
        int index = i * 2 + j;

        if (index >= categories.length) {
          break;
        }

        rowChildren.add(
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: getColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10, height: 25),
                Expanded(
                  child: Text(
                    categories[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      legend.add(Row(
        children: rowChildren,
      ));
    }

    return legend;
  }
}
