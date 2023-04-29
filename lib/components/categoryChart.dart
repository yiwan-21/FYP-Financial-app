import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: PieChart(
            PieChartData(
              sections: getSections(),
              centerSpaceRadius: 40,
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: getLegend()),
        ),
      ],
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
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.lightBlue,
      Colors.purpleAccent,
      Colors.brown,
      Colors.amber,
      Colors.greenAccent,
      Colors.cyan,
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
