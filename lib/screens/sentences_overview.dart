import 'package:flutter/material.dart';
import 'package:projektmodul/current_state_util.dart';
import 'package:projektmodul/page.dart';
import 'package:projektmodul/sentences_util.dart';

class ChooseSenteceScreen extends InsertableElement {

  ChooseSenteceScreen(String title, bool initialized, {super.key}) : super(title, initialized);

  @override
  State<ChooseSenteceScreen> createState() => _ChooseSenteceScreenState();
}

class _ChooseSenteceScreenState extends State<ChooseSenteceScreen> {

  late final Sentences statementSingleton; 
  late CurrentStateUtil stateUtil;

  @override
  void initState() {
    super.initState();
    statementSingleton = Sentences();
    stateUtil = CurrentStateUtil();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).backgroundColor,
      child: ListView.builder(
          itemBuilder: (context, index) => Card(
            key: ValueKey(statementSingleton.statements[index]),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            color: Theme.of(context).primaryColorLight,
            elevation: 4,
            child: ListTile(
              title: Text(statementSingleton.statements[index]!, style: Theme.of(context).textTheme.bodyText2,),
              onTap:() => showAnswers(index),
            ),
          ),
           
          itemCount: statementSingleton.statements.length,
        ),
      );
  }
  

  
  showAnswers(index) {
    stateUtil.setSelectedStatement(index);
    stateUtil.setPage("Select answer");
  }

}
