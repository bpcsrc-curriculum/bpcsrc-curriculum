import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/classes/RefreshNotifier.dart';
import 'package:src_viewer/widgets/LessonApprovalWidget.dart';

import '../classes/IRefresh.dart';
import '../classes/LessonEntry.dart';
import '../misc.dart';

class PublishingPage extends StatefulWidget {
  const PublishingPage({super.key});

  @override
  State<PublishingPage> createState() => _PublishingPageState();
}

class _PublishingPageState extends State<PublishingPage> implements IRefresh{
  Map<String, String> filterSelections = Map<String, String>();
  TextEditingController searchBar = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;
  bool showUnpublishedSubmissions = true;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> fetchSubmissions() async {
    Query<Map<String, dynamic>> initialQuery = db.collection("submissions");
    var resultQuery = (await initialQuery.get()).docs;
    if (resultQuery.length == 1) {
      return resultQuery;
    } else {
      initialQuery = initialQuery.orderBy("Timestamp");
      return (await initialQuery.get()).docs;
    }
  }

  Widget createDropDownFromList(List<String> options, String fieldName) {
    setState(() {
      filterSelections.putIfAbsent(fieldName, () => options.first);
    });
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 8.0),
      child: Row(
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
      ),
    );
  }

  String getFiltersAsString() {
    bool noneSelected = true;
    int amountAdded = 0;
    String output = "";
    for (String s in filterSelections.values) {
      if (s != "None") {
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
  }

  @override
  void refreshPage(){
    print("refreshing publishing page");
    setState(() {

    });
  }

  void toggleUnpublishedSubmissions() {
    setState(() {
      showUnpublishedSubmissions = !showUnpublishedSubmissions;
      print("toggling to " + showUnpublishedSubmissions.toString());
    });
  }

  @override
  void onPageExited() {
    RefreshNotifier().removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = fieldsToUseAsFilters.first;
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
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 25,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ExpandablePanel(
                              header: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Filters",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              collapsed: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                                child: Text(getFiltersAsString()),
                              ),
                              expanded: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  createDropDownFromList(courseLevelOptions, "Course Level"),
                                  createDropDownFromList(csTopicOptions, "CS Topics"),
                                  createDropDownFromList(learningObjectiveOptions, "Learning Suggestions"),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                      flex: 75,
                      child: Padding(
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
                    )
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
                          "There are no submitted materials available at the moment.",
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

                          if (showUnpublishedSubmissions && entry.getSubmissionField("Approved").value != "APPROVED") {
                            return const SizedBox.shrink();
                          }

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
                                  child: LessonApprovalWidget(entry: entry, docRef: submissions[index].reference),
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
      ),
    );
  }
}
