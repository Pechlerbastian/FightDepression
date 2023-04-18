import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projektmodul/current_state_util.dart';
import 'package:projektmodul/page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SessionScreen extends InsertableElement {

  SessionScreen(String title, bool initialized, {super.key}) : super(title, initialized);
  
  get stateUtil => null;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {

  late CurrentStateUtil stateUtil;
  late List<ChartData> _chartData;

  @override
  void initState() {
    requestPermission();
    stateUtil = CurrentStateUtil();
    super.initState();
  }

  Future<void> requestPermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission is granted, continue with file access
    } else {
      // Permission is not granted, show a dialog explaining why
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text('Please grant storage permission to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: stateUtil.loadPersistedData(),
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _chartData = List.generate(stateUtil.predictions.length, (index) => ChartData(index + 1, 0, 0, 0));
            _updateChartData();
            return Card(
              color: Theme.of(context).backgroundColor,
              child: Column(
              children: [
                TextField(style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center, enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Session Counter'
                  ),
                  
                  controller: TextEditingController(text: stateUtil.amountTrained.toString()),
                  onChanged: (value) {
                    stateUtil.amountTrained = int.parse(value);
                  },
                ),
                Expanded(
                    child: stateUtil.predictions.isNotEmpty ?
                      Column(children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                        Text(textAlign: TextAlign.center,
                            "Results",
                            style: Theme.of(context).textTheme.headline2,
                        ),
                        Expanded(child:
                          SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(maximum: 10),
                            series: <ColumnSeries>[
                            ColumnSeries<ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (ChartData data, _) => data.x.toString(),
                                yValueMapper: (ChartData data, _) => data.y1,
                                width: 0.5,
                                color: HSLColor.fromColor(Theme.of(context).primaryColor).withLightness((HSLColor.fromColor(Theme.of(context).primaryColor).lightness + 0.1)).toColor(),
                              ),
                              ColumnSeries<ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (ChartData data, _) => data.x.toString(),
                                yValueMapper: (ChartData data, _) => data.y2,
                                width: 0.5,
                                color:Theme.of(context).primaryColor,
                              ),
                              ColumnSeries<ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (ChartData data, _) => data.x.toString(),
                                yValueMapper: (ChartData data, _) => data.y3,
                                width: 0.5,
                                color:HSLColor.fromColor(Theme.of(context).primaryColor).withLightness((HSLColor.fromColor(Theme.of(context).primaryColor).lightness - 0.1)).toColor(),
                              ),
                          ],
                        ))
                    ],)
                    : 
                    Card(
                      elevation: 4,
                      child:
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(5),
                          ),
                          child:
                            Container(color: Theme.of(context).primaryColorDark, 
                              child: Column(
                                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                  Container(padding: const EdgeInsets.all(16.0), 
                                    child: Text(
                                        "Info: ",
                                        style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1, child: const Divider(color: Colors.blueGrey, thickness: 0.4,)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      textAlign: TextAlign.left,
                                      "This app was made to improve your mood! \n\n"
                                      "If you press start, you will get confronted with " 
                                      "a statement and can select a reapprasial. \n\n"
                                      "Afterwards you can record yourself for three times for selected reapprasial. \n\n"
                                      "This cycle can be done 5 times a day. After this you can train more for yourself. \n\n"
                                      "You will be redirected to this screen every time you finish one cycle. Your results will be displayed here.",
                                      style: Theme.of(context).textTheme.headline2,))
                                ])
                            )
                          ),
                    )      
                ),
                ElevatedButton(
                  onPressed: stateUtil.dailyTrainDone ? null : () {
                    stateUtil.chooseRandomStatement(false);
                    stateUtil.setPage("Select answer");
                  },
                  
                  child: stateUtil.amountTrained == 0 && stateUtil.trainStep == 0 ? Text('Start', style: Theme.of(context).textTheme.bodyText1) 
                                                      : Text('Continue', style: Theme.of(context).textTheme.bodyText1),
                ),
                
              ],
            ),
          );
          } else {
        return  Center(child: Text("Loading...", style: Theme.of(context).textTheme.headline2,) );
      }
    },
    );
  }
  
  void _updateChartData() {
    _chartData = List.generate(stateUtil.predictions.length, (index) => 
    ChartData((index) + 1, 
    (stateUtil.predictions[index]?[0] ?? 0.0) ,
    (stateUtil.predictions[index]?[1] ?? 0.0) , 
    (stateUtil.predictions[index]?[2] ?? 0.0) ));
  
  }

  
  showAnswers(index) {
    stateUtil.setSelectedStatement(index);
    stateUtil.setPage("Select answer");
  }

  @override
  void didUpdateWidget(SessionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateUtil.predictions != stateUtil.predictions) {
      _updateChartData();
    }
  }
  

}


class ChartData {
  ChartData(this.x, this.y1, this.y2, this.y3);

  final int x;
  final double y1;
  final double y2;
  final double y3;
  
}
