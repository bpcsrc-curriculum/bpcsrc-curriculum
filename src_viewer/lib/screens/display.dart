import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/widgets/LessonEntryWidget.dart';
import 'package:src_viewer/misc.dart';

import '../classes/IRefresh.dart';
import '../classes/RefreshNotifier.dart';
import '../modals/PasswordEntryModal.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> with SingleTickerProviderStateMixin implements IRefresh{
  Map<String, String> filterSelections = Map<String, String>();
  TextEditingController searchBar = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> fetchSubmissions() async {
    return (await db.collection("submissions").where("Approved", isEqualTo: "APPROVED").get()).docs;
  }

  Widget createDropDownFromList(List<String> options, String fieldName) {
    setState(() {
      filterSelections.putIfAbsent(fieldName, () => options.first);
    });
    return Row(
      children: [
        Text(
          fieldName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 15,),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(10)
          ),
          child: DropdownButton(
              value: filterSelections[fieldName],
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(value),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  filterSelections[fieldName] = value!;
                  print(filterSelections.values);
                });
              }
          ),
        ),
      ],
    );
  }

  String getFiltersAsString() {
    bool noneSelected = true;
    int amountAdded = 0;
    String output = "";
    for (String s in filterSelections.values) {
      if (s != "All") {
        noneSelected = false;
        if (amountAdded >= 1) {
          output += ", ";
        }
        output += s;
        amountAdded++;
      }
    }
    return noneSelected? "No filters selected." : output;
  }

  @override
  void initState() {
    super.initState();
    RefreshNotifier().addListener(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  void refreshPage(){
    print("refreshing display page");
    setState(() {

    });
  }

  @override
  void onPageExited() {
    RefreshNotifier().removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 75;
    int currentDelay = 0;

    return WillPopScope(
      onWillPop: () async {
        onPageExited();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Socially Responsible Curriculum Viewer",
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                              hintText: "Search for specific keywords"
                          ),
                          controller: searchBar,
                          onChanged: (String value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: createDropDownFromList(courseLevelOptions, "Course Level"),
                                ),
                              ),
                            )
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: createDropDownFromList(csTopicOptions, "CS Topics")
                                ),
                              ),
                            )
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: createDropDownFromList(learningObjectiveOptions, "Learning Objectives")
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: fetchSubmissions(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) { // Successfully loaded data
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>? submissions = snapshot.data;
                    if (submissions != null) {
                      if (submissions.isEmpty) {
                        return const Text(
                          "There are no published materials available at the moment.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        );
                      }
                      return ListView.builder( // Once posts are retrieved, generates ListView
                        itemCount: submissions.length,
                        itemBuilder: (BuildContext context, int index) {
                          LessonEntry entry = LessonEntry.fromMap(submissions[index].data());

                          //can we perform an actual filter?
                          bool searchBarMatch = entry.queryAll(searchBar.text);
                          bool filterMatch = entry.queryFieldMap(filterSelections);
                          if (!searchBarMatch || !filterMatch) {
                            return const SizedBox.shrink();
                          }
                          else {
                            currentDelay+=delayMilliSeconds;
                            return FadeInLeft(
                                delay: Duration(milliseconds: currentDelay),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                                  child: LessonEntryWidget(entry: entry),
                                )
                            );
                          }
                        },
                      );
                    } else { // Problem loading data
                      return const Text("Error loading data");
                    }
                  } else { // Loading data
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.black, size: 75),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionBubble(
          // Menu items
          items: <Bubble>[

            // Floating action menu item
            Bubble(
              title:"Refresh Data",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).primaryColor,
              icon:Icons.refresh,
              titleStyle:const TextStyle(fontSize: 16 , color: Colors.white),
              onPress: () {
                setState(() {
                });

                _animationController.reverse();
              },
            ),
            Bubble(
              title: "Submit Material",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).primaryColor,
              icon:Icons.add,
              titleStyle: const TextStyle(fontSize: 16 , color: Colors.white),
              onPress: () {
                String url = formURL;
                html.window.open(url, "Submission Form");

                _animationController.reverse();
              },
            ),
            Bubble(
              title:"Approve Material",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).primaryColor,
              icon:Icons.people,
              titleStyle:const TextStyle(fontSize: 16 , color: Colors.white),
              onPress: () {
                createPasswordEntryModal(context, TextEditingController());

                _animationController.reverse();
              },
            ),
          ],

          animation: _animation,
          onPress: () => _animationController.isCompleted
              ? _animationController.reverse()
              : _animationController.forward(),
          iconColor: Colors.white,
          iconData: Icons.settings,
          backGroundColor: Theme.of(context).primaryColor,
        )
      ),
    );
  }
}
