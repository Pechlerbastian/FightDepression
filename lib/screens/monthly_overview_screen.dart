import 'package:flutter/material.dart';
import 'package:projektmodul/current_state_util.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../page.dart';

class MonthsOverview extends InsertableElement {

  MonthsOverview(String title, bool initialized, {super.key}) : super(title, true);

  @override
  _MonthsOverviewState createState() => _MonthsOverviewState();
}

class _MonthsOverviewState extends State<MonthsOverview> {
  late CurrentStateUtil currentStateUtil;

  @override
  void initState() {
    currentStateUtil = CurrentStateUtil();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
          child: Column(
            children: [
              SizedBox(
                width: 200.0,
                height: 50.0,
                child:
                  DropdownButton<String>(
                    value: currentStateUtil.loadedMonth.isEmpty ? null : currentStateUtil.loadedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        currentStateUtil.loadedMonth = newValue!;
                      });
                      currentStateUtil.loadSpecifiedMonthValue();
                    },
                    items: currentStateUtil.availableMonths.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
              ),
            FutureBuilder<Map<String, List<double>>>(
            future: currentStateUtil.loadSpecifiedMonthValue(),
            builder: (BuildContext context, AsyncSnapshot<Map<String, List<double>>> snapshot) {
              if (snapshot.hasData) {
                List<ChartData> chartData = snapshot.data!.entries.map((entry) => ChartData(entry.key, entry.value[0], entry.value[1])).toList();
                  return  Expanded(child:
                    SfCartesianChart(
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        
                      ),
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: 'Date',
                        ),
                        majorGridLines: const MajorGridLines(
                          width: 0,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 10,
                        axisLine: AxisLine(width: 0),
                        majorTickLines: MajorTickLines(size: 0),
                        minorTickLines: MinorTickLines(size: 0),
                        title: AxisTitle(
                          text: 'Score',
                        ),
                        majorGridLines: MajorGridLines(
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        minorGridLines: MinorGridLines(
                          width: 1,
                          color: Colors.grey.shade100,
                        ),
                      ),
                      series: <LineSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: chartData,
                          name: "Start",
                          xValueMapper: (ChartData data, _) =>data.date,
                          yValueMapper: (ChartData data, _) => data.score1,
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: chartData,
                          name: "End",
                          xValueMapper: (ChartData data, _) => data.date,
                          yValueMapper: (ChartData data, _) => data.score2,
                        )
                      ],
                    )
                  );
              } else {
                return const Text("");
              }
            },
          )
        ],
      ),
    );
  }
}

class ChartData {
  final String date;
  final double score1;
  final double score2;

  ChartData(this.date, this.score1, this.score2);
}