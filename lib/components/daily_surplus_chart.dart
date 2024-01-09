import 'package:financial_app/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/constant.dart';
import '../components/custom_input_decoration.dart';
import '../providers/transaction_provider.dart';

class DailySurplusData {
  final DateTime date;
  double surplus;

  void addSurplus(double surplus) {
    this.surplus += surplus;
  }

  DailySurplusData(this.date, this.surplus);
}

class DailySurplusChart extends StatefulWidget {
  const DailySurplusChart({super.key});

  @override
  State<DailySurplusChart> createState() => _DailySurplusChartState();
}

class _DailySurplusChartState extends State<DailySurplusChart> {
  final _formKey = GlobalKey<FormState>();
  DateTime _surplusStartDate =
      getOnlyDate(DateTime.now().subtract(const Duration(days: 7)));
  DateTime _surplusEndDate = getOnlyDate(DateTime.now());

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month - 6, 0);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _surplusStartDate,
      // now -6 months
      firstDate: firstDate,
      lastDate: DateTime.now().subtract(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        _surplusStartDate = picked;
        _surplusEndDate = picked.add(const Duration(days: 7));
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month - 6, 0);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _surplusEndDate,
      // now -6 months
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _surplusEndDate = picked;
        _surplusStartDate = picked.subtract(const Duration(days: 7));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<TransactionProvider>(
          builder: (context, totalTransactionProvider, _) {
            List<DailySurplusData> dailySurplusData = totalTransactionProvider
                .getDailySurplusData(_surplusStartDate, _surplusEndDate);
            if (dailySurplusData.isNotEmpty) {
              return SfCartesianChart(
                primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Date')),
                // Chart title
                title: ChartTitle(text: 'Cumulative difference of total income and expense'),
                // Enable legend
                // legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: true),
                onTooltipRender: (TooltipArgs tooltipArgs) {
                  if (tooltipArgs.dataPoints != null &&
                      tooltipArgs.dataPoints!.isNotEmpty) {
                    int index = tooltipArgs.pointIndex!.toInt();
                    CartesianChartPoint<dynamic> point =
                        tooltipArgs.dataPoints![index];
                    num surplus = point.y;
                    // Setting the tooltip header
                    tooltipArgs.header = surplus >= 0 ? 'Surplus' : 'Deficit';
                    // Setting the tooltip text
                    tooltipArgs.text = '${point.x}: ${surplus.toStringAsFixed(2)}';
                  }
                },
                series: <ChartSeries<DailySurplusData, String>>[
                  LineSeries <DailySurplusData, String>(
                    dataSource: dailySurplusData,
                    xValueMapper: (DailySurplusData record, _) =>
                        '${Constant.monthLabels[record.date.month - 1]} ${record.date.day}',
                    yValueMapper: (DailySurplusData record, _) =>
                        record.surplus,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                    dataLabelMapper: (DailySurplusData record, _) =>
                        record.surplus.toStringAsFixed(2),
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Text(
              'Choose the start date or the end date',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
              )),
        ),
        Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectStartDate(context);
                      },
                      decoration: customInputDecoration(
                        labelText: 'Start Date',
                        helperText: 'Start date: Auto set to 8 days before End date',
                        helperMaxLines: 2,
                      ), 
                      controller: TextEditingController(
                        text: _surplusStartDate.toString().substring(0, 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectEndDate(context);
                      },
                      decoration: customInputDecoration(
                        labelText: 'End Date',
                        helperText: 'End date: Auto set to 8 days after Start date',
                        helperMaxLines: 2,
                      ),
                      controller: TextEditingController(
                        text: _surplusEndDate.toString().substring(0, 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ))
      ],
    );
  }
}
