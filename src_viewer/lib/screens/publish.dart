import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController filterQuery = TextEditingController();
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
        body: Column(
          children: [
            AnimSearchAppBar(
              cancelButtonText: "Cancel",
              hintText: 'Search for a specific assignment with a keyword',
              cSearch: filterQuery,
              onChanged: (String entry) {
                setState(() {
                });
              },
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Row(
                  children: [
                    const Text(
                      "Approve Submitted Material",
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: DropdownButton(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            items: fieldsToUseAsFilters.map<DropdownMenuItem<String>>((String value) {
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
                                dropdownValue = value!;
                              });
                            }
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: JustTheTooltip(
                        backgroundColor: Color(0xFF333333),
                        content: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              showUnpublishedSubmissions? "Show all submissions": "Show only published submissions",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              )
                          ),
                        ),
                        child: IconButton(
                            onPressed: () {
                              toggleUnpublishedSubmissions();
                            },
                            icon: const Icon(
                                Icons.filter_list_alt,
                                color: Colors.white
                            )
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
                          if (filterQuery.text.isNotEmpty && !entry.matchesQuery(filterQuery.text, dropdownValue)) {
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
