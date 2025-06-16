// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/widgets/LessonEntryWidget.dart';
import 'package:src_viewer/misc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:src_viewer/config.dart';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'dart:developer';

import '../classes/IRefresh.dart';
import '../classes/RefreshNotifier.dart';
import '../modals/PasswordEntryModal.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import '../main.dart' show analytics, AnalyticsEvents;

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class StringMultiSelectDropDown extends StatelessWidget {
  final List<String> options;
  final List<String> initialSelected;
  final void Function(List<String>) onChanged;
  final String hint;
  final Map<String, String>? displayNameMap;

  const StringMultiSelectDropDown({
    Key? key,
    required this.options,
    required this.initialSelected,
    required this.onChanged,
    this.hint = "Select options",
    this.displayNameMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> displayInitialSelected = initialSelected;
    if (displayNameMap != null) {
      displayInitialSelected = initialSelected.map((value) => 
        displayNameMap![value] ?? value
      ).toList();
    }

    return CustomDropdown<String>.multiSelect(
      items: options,
      initialItems: displayInitialSelected,
      hintText: hint,
      onListChanged: (List<String> selectedDisplayNames) {
        if (displayNameMap != null) {
          List<String> filterValues = selectedDisplayNames.map((displayName) {
            String? filterValue = displayNameMap!.entries
                .firstWhere((entry) => entry.value == displayName,
                    orElse: () => MapEntry(displayName, displayName))
                .key;
            return filterValue;
          }).toList();
          onChanged(filterValues);
        } else {
          onChanged(selectedDisplayNames);
        }
      },
      maxlines: 3,
    );
  }
}

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> with SingleTickerProviderStateMixin implements IRefresh{
  Map<String, List<String>> filterSelections = {};
  TextEditingController searchBar = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;
  String sortOption = 'newest'; // 'newest', 'mostReviews'

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

    // Log screen view
    _logScreenView();
  }

  Future<void> _logScreenView() async {
    try {
      await analytics.logScreenView(
        screenName: 'display_page',
        screenClass: 'DisplayPage',
      );
      if (Config.debugAnalytics) {
        print('Analytics Screen View Sent: display_page');
      }
    } catch (e) {
      print('Error sending screen view: $e');
    }
  }

  Future<void> _logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (Config.debugAnalytics) {
        print('Analytics Event Sent: $name');
        print('Parameters: $parameters');
      }
    } catch (e) {
      print('Error sending analytics event $name: $e');
    }
  }

  // This returns every approved lesson in firebase
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> fetchSubmissions() async {
    try {
      // Log data fetch
      await _logEvent('data_fetch', {
        'source': 'display_page',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final docs = await db.collection("submissions")
          .where("Approved", isEqualTo: "APPROVED")
          .get();
      
      // Log successful fetch
      await _logEvent('lesson_view', {
        'count': docs.docs.length,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await analytics.logEvent(
    name: 'lesson_view',
    parameters: {
      'count': docs.docs.length,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

      return docs.docs;
    } catch (e) {
      // Log error
      await _logEvent('error_occurred', {
        'error_type': 'fetch_error',
        'error_message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      rethrow;
    }
  }

  void _handleSearch(String query) async {
    if (query.isNotEmpty) {
      await _logEvent('search_performed', {
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void _handleFilterChange(String filterName, List<String> selectedValues) async {
    await _logEvent('filter_applied', {
      'filter_name': filterName,
      'selected_values': selectedValues.join(','),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _handleLessonApproval() async {
    await _logEvent('lesson_approved', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String getFiltersAsString() {
    bool noneSelected = true;
    int amountAdded = 0;
    String output = "";

    filterSelections.forEach((field, filters) {
      // Skip this field if "All" is selected or the list is empty.
      if (filters.isEmpty || filters.contains("All")) {
        return; // continue to the next field.
      }
      noneSelected = false;

      // If you want to display the field name along with its filters, uncomment:
      // String fieldOutput = "$field: ${filters.join(', ')}";
      // Otherwise, just join the selected filters:
      String fieldOutput = filters.join(", ");

      if (amountAdded > 0) {
        output += ", ";
      }
      output += fieldOutput;
      amountAdded++;
    });

    return noneSelected ? "No filters selected." : output;
  }

  @override
  void refreshPage(){
    // Log refresh event
    analytics.logEvent(
      name: 'page_refresh',
      parameters: {
        'page': 'display',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    if (Config.logAnalyticsEvents) {
      print('Analytics Event: page_refresh');
    }
    
    print("refreshing display page");
    setState(() {});
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
                            onChanged: _handleSearch,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StringMultiSelectDropDown(
                              options: courseLevelOptions,
                              initialSelected:
                                  filterSelections["Course Level"] ?? [],
                              hint: "Select Course Level",
                              displayNameMap: courseLevelDisplayNames,
                              onChanged: (selected) {
                                filterSelections["Course Level"] = selected;
                                _handleFilterChange("Course Level", selected);
                                setState(() {});
                              },

                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StringMultiSelectDropDown(
                              options: csTopicOptions,
                              initialSelected:
                                  filterSelections["CS Topics"] ?? [],
                              hint: "Select CS Topics",
                              onChanged: (selected) {
                                filterSelections["CS Topics"] = selected;
                                _handleFilterChange("CS Topics", selected);
                                setState(() {});
                              },

                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StringMultiSelectDropDown(
                              options: learningObjectiveOptions,
                              initialSelected:
                                  filterSelections["Learning Objectives"] ?? [],
                              hint: "Select Learning Objectives",
                              onChanged: (selected) {
                                filterSelections["Learning Objectives"] =
                                    selected;
                                _handleFilterChange(
                                    "Learning Objectives", selected);
                                setState(() {});
                              },

                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StringMultiSelectDropDown(
                              options: srcTopicsOptions,
                              initialSelected:
                                  filterSelections["Domain/Societal Factor"] ?? [],
                              hint: "Select Domain/Societal Factor",
                              onChanged: (selected) {
                                filterSelections["Domain/Societal Factor"] =
                                    selected;
                                _handleFilterChange(
                                    "Domain/Societal Factor", selected);
                                setState(() {});
                              },

                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StringMultiSelectDropDown(
                              options: collaboratorOptions,
                              initialSelected:
                                  filterSelections["Campus"] ?? [],
                              hint: "Select Campus",
                              onChanged: (selected) {
                                filterSelections["Campus"] = selected;
                                _handleFilterChange("Campus", selected);
                                setState(() {});
                              },

                            ),
                          )),
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
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>? submissions = snapshot.data; // Converts data into a list of Firestore documents.
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

                      // List the current options selected (This does filtering)
                      List<LessonEntry> filteredSubmissions = submissions
                          .map((doc) => LessonEntry.fromMap(doc.data()))
                          // entry.queryFieldMap(filterSelections) → Filters based on dropdown selections.
                          .where((entry) => entry.queryAll(searchBar.text) && entry.queryFieldMap(filterSelections))
                          .toList();

                      // Sort logic
                      filteredSubmissions.sort((a, b) {
                        int aReviews = 0;
                        int bReviews = 0;
                        if (a.fields.containsKey('Reviews') && a.fields['Reviews']!.value is List) {
                          aReviews = (a.fields['Reviews']!.value as List).length;
                        } else if (a.fields.containsKey('Reviews')) {
                          try {
                            aReviews = (a.fields['Reviews']!.value as List<dynamic>).length;
                          } catch (_) {
                            aReviews = 0;
                          }
                        }
                        if (b.fields.containsKey('Reviews') && b.fields['Reviews']!.value is List) {
                          bReviews = (b.fields['Reviews']!.value as List).length;
                        } else if (b.fields.containsKey('Reviews')) {
                          try {
                            bReviews = (b.fields['Reviews']!.value as List<dynamic>).length;
                          } catch (_) {
                            bReviews = 0;
                          }
                        }
                        int aDate = 0;
                        int bDate = 0;
                        if (a.fields.containsKey('Upload Date')) {
                          aDate = int.tryParse(a.fields['Upload Date']!.value) ?? 0;
                        }
                        if (b.fields.containsKey('Upload Date')) {
                          bDate = int.tryParse(b.fields['Upload Date']!.value) ?? 0;
                        }
                        switch (sortOption) {
                          case 'newest':
                            return bDate.compareTo(aDate);
                          case 'mostReviews':
                            return bReviews.compareTo(aReviews);
                          default:
                            return bDate.compareTo(aDate);
                        }
                      });

                      // Now build the UI after
                      return Column(
                        children: [
                          Container(
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${filteredSubmissions.length} result${filteredSubmissions.length == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  DropdownButton<String>(
                                    value: sortOption,
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 32),
                                    dropdownColor: Theme.of(context).primaryColor,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'newest',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today, size: 24, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Newest to Oldest'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'mostReviews',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 24, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Most Reviewed'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          sortOption = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredSubmissions.length,
                              itemBuilder: (BuildContext context, int index) {
                                currentDelay += delayMilliSeconds;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                                  child: LessonEntryWidget(entry: filteredSubmissions[index]),
                                );
                              },
                            ),
                          ),
                        ],
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

Bubble(
                title: "Approve Material",
                iconColor: Colors.white,
                bubbleColor: Theme.of(context).primaryColor,
                icon: Icons.people,
                titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  _handleLessonApproval();
                  createPasswordEntryModal(context, TextEditingController());
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
