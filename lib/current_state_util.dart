import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:projektmodul/page.dart';
import 'package:projektmodul/screens/monthly_overview_screen.dart';
import 'package:projektmodul/screens/reappraisal_screen.dart';
import 'package:projektmodul/screens/session_screen.dart';
import 'package:projektmodul/screens/recording_screen.dart';
import 'package:projektmodul/screens/sentences_overview.dart';
import 'package:projektmodul/sentences_util.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
class CurrentStateUtil{
 
  static final CurrentStateUtil _instance = CurrentStateUtil._internal();
    factory CurrentStateUtil() => _instance;
   
    late int selectedStatement;
    late int selectedAnswer;
    late int currentPageIndex;
    late DateTime currentDate;
    late String loadedMonth = "";
    late int amountTrained;
    late int trainStep;
    Map<int, List<double>> predictions = {};

    List<String> availableMonths = [];
    Map<String, List<double>> monthData = {};

    Timer? _timer;

    bool dailyTrainDone = false;
    bool initialized = false;

    List<InsertableElement> pages = <InsertableElement>[

      SessionScreen("Session", true),
      ReappraisalScreen("Select answer", true),
      RecordingScreen("Record and evaluate", true),
      MonthsOverview("Months", true)
      
      ];

  CurrentStateUtil._internal() {
    currentPageIndex = 0;
    selectedAnswer = 0;
    trainStep= 0;
    amountTrained =0;
    currentDate = DateTime.now();
    chooseRandomStatement(true);
    _startTimer();
  }

  void chooseRandomStatement(bool forInit) {
    if (trainStep > 2 || forInit) {
      selectedStatement = Random().nextInt(Sentences().statements.length);
      trainStep = 0;
    }
  }

  void persistData() async{
    Map<String, dynamic> newEntry = {
      currentDate.toString().split(' ')[0]: predictions.map((key, value) => MapEntry(key.toString(), value))
    };
    final dir = await getExternalStorageDirectory();

    // Determine the file name for the current month
    final fileName = '${currentDate.year}-${currentDate.month}.json';
    final filePath = "${dir!.path}/$fileName";

    // Check if the file for the current month already exists
    final file = File(filePath);
    if (file.existsSync()) {
      // If the file exists, read its contents and add the new entry
      final contents = file.readAsStringSync();
      final data = jsonDecode(contents);
      final convertedData = data.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k.toString(), v))));
      if(!convertedData.containsKey(currentDate.toString().split(' ')[0])){
        convertedData[currentDate.toString().split(' ')[0]] = {};
      }
      // this construct is needed so that data types are correct
      for (int i in predictions.keys){
        var list = [];
        for (double value in predictions[i]!){
          list.add(value);
        }
        convertedData[currentDate.toString().split(' ')[0]][i.toString()] = list;

      }
      final updatedContents = jsonEncode(convertedData);
      file.writeAsStringSync(updatedContents);
    } else {
      // If the file doesn't exist, create a new file with the new entry
      final data = newEntry;
      final contents = jsonEncode(data);
      file.writeAsStringSync(contents);
    
      const fileNameMonths = 'months.json';
      final filePathMonths = "${dir.path}/$fileNameMonths";

      final fileMonths = File(filePathMonths);
      // this file is already created by loading so it should exist
      if (fileMonths.existsSync()) {
        final contentsMonths = fileMonths.readAsStringSync();
        final dataMonths = jsonDecode(contentsMonths);
        availableMonths = [];
        if(dataMonths["Months"].isNotEmpty){
          for(String month in dataMonths){
            availableMonths.add(month);
          }
        }
        availableMonths.add("${currentDate.year}-${currentDate.month}");
        final updatedMonths = jsonEncode({"Months": availableMonths});
        fileMonths.writeAsStringSync(updatedMonths);
      }
    }
  } 

  Future<void> loadPersistedData() async{
    if(!initialized){
      // Determine the file name for the current month
      final dir = await getExternalStorageDirectory();

      // Determine the file name for the current month
      const fileNameMonths = 'months.json';
      final filePathMonths = "${dir!.path}/$fileNameMonths";

      // Check if the file for the current month already exists
      final fileMonths = File(filePathMonths);
      if (fileMonths.existsSync()) {
        final contentsMonths = fileMonths.readAsStringSync();
        final dataMonths = jsonDecode(contentsMonths);
        
        var months = dataMonths["Months"];
        if(months.isNotEmpty){
          availableMonths = [];
          for(String month in months){
            availableMonths.add(month);
          }
        }
        else{
          availableMonths = [];
        }
      }
      else {
        // Create a new file with default content
        final defaultContent = jsonEncode({"Months": []});
        fileMonths.writeAsStringSync(defaultContent);

        availableMonths = [];
      }
      // Determine the file name for the current month
      final fileName = '${currentDate.year}-${currentDate.month}.json';
      final filePath = "${dir.path}/$fileName";

      // Check if the file for the current month already exists
      final file = File(filePath);
      trainStep = 0;
      if (file.existsSync()) {
        // If the file exists, read its contents and add the new entry
        final contents = file.readAsStringSync();
        final data = jsonDecode(contents);
        var dayKey = currentDate.toString().split(' ')[0];
        if (data.containsKey(dayKey)) {
          // this construct is needed so that data types are correct
          for (String i in data[dayKey].keys){
            predictions[int.parse(i)] = [];
            for (double value in data[dayKey][i]){

              predictions[int.parse(i)]!.add(value); 
            }
          }
          amountTrained = predictions.length;
          dailyTrainDone = amountTrained > 4;
          initialized = true;
          return;
        }
      } 
      initialized = true;
      predictions = {};
      amountTrained = 0;
    }
  }
  
  void selectMonthValue(int i) {
    loadedMonth = availableMonths[i];
  }

  Future<Map<String, List<double>>> loadSpecifiedMonthValue() async{
    final dir = await getExternalStorageDirectory();
     // Determine the file name for the current month
    final fileName = '$loadedMonth.json';
    final filePath = "${dir!.path}/$fileName";

    // Check if the file for the current month already exists
    final file = File(filePath);
    trainStep = 0;
    if (file.existsSync()) {
      // If the file exists, read its contents and add the new entry
      final contents = file.readAsStringSync();
      final data = jsonDecode(contents);
      Map<String, List<double>> values = {};
      for(String key in data.keys){
        values[key] = [];
        values[key]?.add(data[key][data[key].keys.first].first);
        values[key]?.add(data[key][data[key].keys.last].last);

      }
    return values;

    }
    return {};
  
  }

  // Start timer which is needed for saving data with according date
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != currentDate.day) {
        updateCurrentDate();
        amountTrained = 0;
      }
    });
  }

  void updateCurrentDate() {
    currentDate = DateTime.now();
  }
  
   void dispose() {
    _timer?.cancel();
  }

  set selectedIndex(int index) {
    currentPageIndex = index;
    if (_onSelectionChanged != null) {
      _onSelectionChanged!(index);
    }
  }

  void Function(int)? _onSelectionChanged;

  void addListener(void Function(int) listener) {
    _onSelectionChanged = listener;
  }

  void removeListener() {
    _onSelectionChanged = null;
  }

  void setSelectedStatement(int index){
      selectedStatement = index;
  }

  void setSelectedAnswer(int index){
    selectedAnswer = index;
  }

  void setPage(String pageTitle){
    for(final page in pages){
      if(page.title == pageTitle){
        currentPageIndex = pages.indexOf(page);
        
         if (_onSelectionChanged != null) {
            _onSelectionChanged!(currentPageIndex);
         }
        return;
      }
    }
    throw Exception("Page not initialized");
  }

  void endDailyTraining() {
    pages.add(ChooseSenteceScreen("Choose Sentence", true)); 
    dailyTrainDone = true;

  }

}