import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

class Sentences {

  static final Sentences _instance = Sentences._internal();
    factory Sentences() => _instance;
    late Map<int, String> statements = {};
    late Map<int, List<String>> reappraisals = {};

    Sentences._internal() {
      parseXml();
    }

  Future<dynamic> loadContent()async{
    final response = await rootBundle.loadString('assets/sources/arrays.xml');
    return response;
  }

  Future<void> parseXml() async {   
    final response = await loadContent();
    final parsedContent = xml.XmlDocument.parse(response);
    var node = parsedContent.findElements("resources").first;
    var statementNodes = node.findElements("string-array").first.findElements("item");

    
    List<String> sentences = [];
    for(final statement in statementNodes){
      sentences.add(statement.text);
    }
    for(int i = 0; i < sentences.length; i++){
      statements[i] = sentences[i];
    }
    var reappraisalSentences = node.findElements("string-array").last.findElements("item");
    var answerList = []; 
    for (final reappraisal in reappraisalSentences){
      answerList.add(reappraisal.text);
    }
    for(int i=0; i<sentences.length; i++){
      List<String> currentReappraisals = [answerList[i], answerList[i+1], answerList[i+2]];
      reappraisals[i] = currentReappraisals;
    }
    return;
  }
}