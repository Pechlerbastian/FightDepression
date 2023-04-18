import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projektmodul/current_state_util.dart';
import 'package:projektmodul/page.dart';

import 'package:projektmodul/sentences_util.dart';

class ReappraisalScreen extends InsertableElement {
  ReappraisalScreen(String title, bool initialized, {super.key}) : super(title, true);

  @override
  State<ReappraisalScreen> createState() => _ReappraisalScreenState();
}

class _ReappraisalScreenState extends State<ReappraisalScreen> {

  late String title;
  late List<String> reappraisalSentences;
  late CurrentStateUtil currentStateUtil;
  late Sentences sentencesUtil;
  Map<int, bool> selectedFlag = {}; 
  Widget? errorMessage;
  bool showErrorMessage = false;
  _ReappraisalScreenState();


  @override
  void initState() {
    sentencesUtil = Sentences();
    currentStateUtil = CurrentStateUtil();
    title = sentencesUtil.statements[currentStateUtil.selectedStatement]!;
    reappraisalSentences = sentencesUtil.reappraisals[currentStateUtil.selectedStatement]!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).backgroundColor,
      child: Column(

        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).secondaryHeaderColor , 
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                    Text(textAlign: TextAlign.center,
                        title,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                  
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ]
                ),
              ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Expanded(child:
            ListView.builder(
              itemBuilder: (builder, index) {
                selectedFlag[index] = selectedFlag[index] ?? false;  
                bool isSelected = selectedFlag[index]!;

                return 
                  Column(children: [Card(
                   
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    color: Theme.of(context).primaryColorLight, 
                    child: 
                      ListTile(
                        onTap: () => onTap(isSelected, index),
                        title: Text(reappraisalSentences[index], textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText2),
                        leading: _buildSelectIcon(isSelected, reappraisalSentences),  // updated
                      ),)
                      
                    ]
                  );
              },
                itemCount: reappraisalSentences.length
              ),
          ),
          if(showErrorMessage) errorMessage!, 
          Stack(
            children: <Widget>[
              
              Align(
                
                alignment: Alignment.bottomRight,
                child: 
                Container(
                  margin: EdgeInsets.only(bottom: 16, right: 16),
                  child:
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () => goToRecordingScreen(),
                      tooltip: 'Start reapprasial process',
                      child: const Icon(Icons.play_arrow, color: Colors.white,),
                   ),
                ),
          )],
          ),
          
      ]),);
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      for(int i = 0; i < selectedFlag.length; i++){
        if(i != index);
          selectedFlag[i] = false;
      }
      selectedFlag[index] = !isSelected;
      showErrorMessage = false;
    });
   
  }
  Widget _buildSelectIcon(bool isSelected, List data) {
  return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).primaryColor,
    );
  }

  void goToRecordingScreen(){
    bool isAnswerSelected = false;
    for(int selected in selectedFlag.keys){
      if(selectedFlag[selected]!){
        currentStateUtil.selectedAnswer = selected;
        currentStateUtil.setPage("Record and evaluate");
        return;
      }
    }
    setState(() {
      errorMessage = const Text("Please select an answer first");
    });
    showErrorMessage = true;
    
  }
}
