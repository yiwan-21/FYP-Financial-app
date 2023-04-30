import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class CategoryChart extends StatefulWidget {
  final List<String> categories;
  final List<double> values;

  const CategoryChart(this.categories, this.values, {super.key});

  @override
  State<StatefulWidget> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Constants.isMobile(context) ? double.infinity : 768,
        maxHeight: Constants.isMobile(context) ? 300 : double.infinity,
      ),
      child: Flex(
        direction:
            Constants.isMobile(context) ? Axis.vertical : Axis.horizontal,
        children: [
          Flexible(
            flex: Constants.isMobile(context) ? 2 : 1,
            child: SizedBox(
              height: Constants.isMobile(context) ? 200 : 220,
              child: PieChart(
                PieChartData(
                  sections: getSections(),
                  centerSpaceRadius: Constants.isMobile(context) ? 40 : 50,
                  sectionsSpace: 0,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response != null) {
                          touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
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
            // flex: Constants.isMobile(context) ? 1 : 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: getLegend()),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < widget.categories.length; i++) {
      sections.add(
        PieChartSectionData(
          value: widget.values[i],
          color: getColor(i),
          title:
              '${(widget.values[i] / widget.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
          radius: touchedIndex == i ? 60 : 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: touchedIndex == i ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return sections;
  }

  Color getColor(int index) {
    // Define a list of colors to use
    const List<Color> colors = [
      Color.fromRGBO(34, 116, 171, 1),
      Colors.lightBlue,
      Color.fromRGBO(128, 221, 220, 1),
      // Color.fromRGBO(230, 246, 157, 1),
      Color.fromRGBO(255, 255, 224, 1),
      Color.fromRGBO(255, 174, 164, 1),
      Color.fromRGBO(231,93,111, 1),
      Color.fromRGBO(184, 109, 219, 1),
      // Color.fromRGBO(245, 185, 130, 1),
    ];

    // If the index is out of range, return a random color
    if (index >= colors.length) {
      return Color.fromRGBO(
        100 + index * 10,
        50 + index * 5,
        150 + index * 15,
        1,
      );
    }

    // Otherwise, return the color at the specified index
    return colors[index];
  }

  List<Widget> getLegend() {
    List<Widget> legend = [];

    int numRows = (widget.categories.length / 2).ceil();

    for (int i = 0; i < numRows; i++) {
      List<Widget> rowChildren = [];

      for (int j = 0; j < 2; j++) {
        int index = i * 2 + j;

        if (index >= widget.categories.length) {
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
                    widget.categories[index],
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
