import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../firebaseInstance.dart';
import '../constants.dart';

class CategoryChart extends StatefulWidget {
  final bool? isStateUpdated;

  const CategoryChart({this.isStateUpdated, super.key});

  @override
  State<StatefulWidget> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  List<String> _categories = [];
  Future<Map<String, double>> _futureMap = Future.value({});
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _futureMap = _getTransactionData();
  }

  @override
  void didUpdateWidget (covariant CategoryChart oldWidget) {
    if (widget.isStateUpdated != null && widget.isStateUpdated!) {
      _updateTransactionsData();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateTransactionsData() {
    setState(() {
      _futureMap = _getTransactionData();
    });
  }

  Future<Map<String, double>> _getTransactionData() async {
    Map<String, double> data = {};
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('isExpense', isEqualTo: true)
        .orderBy('date', descending: false)
        .get()
        .then((value) {
      for (var transaction in value.docs) {
        final category = transaction['category'];
        final amount = transaction['amount'].toDouble();
        if (data.containsKey(category)) {
          data[category] = data[category]! + amount;
        } else {
          data[category] = amount;
        }
      }
    });
    _categories = data.keys.toList();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureMap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Constants.isMobile(context) ? double.infinity : 768,
                maxHeight: Constants.isMobile(context) ? 300 : double.infinity,
              ),
              child: Flex(
                direction: Constants.isMobile(context)
                    ? Axis.vertical
                    : Axis.horizontal,
                children: [
                  Flexible(
                    flex: Constants.isMobile(context) ? 2 : 1,
                    child: SizedBox(
                      height: Constants.isMobile(context) ? 200 : 220,
                      child: PieChart(
                        PieChartData(
                          sections: getSections(snapshot.data!),
                          centerSpaceRadius:
                              Constants.isMobile(context) ? 40 : 50,
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
                    // flex: Constants.isMobile(context) ? 1 : 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: getLegend()),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
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
              '${(values[i] / values.reduce((double a, double b) => a + b) * 100).toStringAsFixed(0)}%',
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
      Color.fromRGBO(128, 221, 220, 1),
      Color.fromRGBO(246, 214, 153, 1),
      Color.fromRGBO(255, 174, 164, 1),
      Color.fromRGBO(31, 120, 190, 1),
      Color.fromRGBO(231, 93, 111, 1),
      Color.fromRGBO(174, 74, 174, 1),
      Colors.lightBlue,
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

    int numRows = (_categories.length / 2).ceil();

    for (int i = 0; i < numRows; i++) {
      List<Widget> rowChildren = [];

      for (int j = 0; j < 2; j++) {
        int index = i * 2 + j;

        if (index >= _categories.length) {
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
                    _categories[index],
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
