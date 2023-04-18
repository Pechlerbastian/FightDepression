import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projektmodul/sentences_util.dart';
import './custom_app_bar.dart';

import 'current_state_util.dart';

class BasicPage extends StatefulWidget {
  const BasicPage({Key? key}) : super(key: key);

  @override
  _BasicPageState createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  late CurrentStateUtil currentStateUtil;
  late Sentences sentences;
  late int currentPageIndex;
  late List<ListTile> navigationItems;

  
  
   @override
  void initState() {
    sentences = Sentences();
    currentStateUtil = CurrentStateUtil();
    currentStateUtil.addListener(_onSelectionChanged);   
    
    super.initState();
  }
  
  void _onSelectionChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Fight Depression',
      drawer: Drawer(
        child: Container(
          color: Color.fromARGB(230, 255, 255, 255),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 0, 47, 86),
                      blurRadius: 10.0,
                      offset: Offset(0.0, 5.0),
                    ),
                  ],
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                            ),
                            child: IconButton(icon: 
                              const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: (){Navigator.of(context).pop();},
                          )
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.headline1
                  ),
                  Container(
                    width: 30,
                  ),
                ],
              ),
            
              ),
              ListTile(
                title: Text('Current Session', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
                onTap: () {
                  currentStateUtil.setPage('Session');
                  Navigator.of(context).pop();
                },
              ),
              currentStateUtil.dailyTrainDone ? 
              ListTile(
                title: Text('Choose Sentence', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
                onTap: () {
                  currentStateUtil.setPage('Choose Sentence');
                  Navigator.of(context).pop();
                },
              )
              :
              Container(),
              ListTile(
                title: Text('Select answer', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
                onTap: () {
                  currentStateUtil.setPage('Select answer');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Record and evaluate', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
                onTap: () {
                  currentStateUtil.setPage('Record and evaluate');
                  Navigator.of(context).pop();
                },
              ),
               ListTile(
                title: Text('Months Overview', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
                onTap: () {
                  currentStateUtil.setPage('Months');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
          onDrawerChanged: (isDrawerOpen) {
            // Do something when the drawer is opened or closed.
          },
        body: Center(
          child: currentStateUtil.pages[currentStateUtil.currentPageIndex],
        )
    );
  }
}

abstract class InsertableElement extends StatefulWidget{
  InsertableElement(this.title, this.initialized, {super.key});
  final String title;
  late bool initialized;
 
}
