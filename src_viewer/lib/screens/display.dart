import 'package:anim_search_app_bar/anim_search_app_bar.dart';
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
  String dropdownValue = fieldsToUseAsFilters.first;
  TextEditingController filterQuery = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> fetchSubmissions() async {
    return (await db.collection("submissions").where("Approved", isEqualTo: "APPROVED").get()).docs;
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
                      "Socially Responsible Curriculum Viewer",
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
                          if (filterQuery.text.isNotEmpty && !entry.matchesQuery(filterQuery.text, dropdownValue)) {
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
