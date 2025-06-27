import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/classes/RefreshNotifier.dart';
import 'package:src_viewer/widgets/LessonApprovalWidget.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../classes/IRefresh.dart';
import '../classes/LessonEntry.dart';
import '../misc.dart';

class PublishingPage extends StatefulWidget {
  const PublishingPage({super.key});

  @override
  State<PublishingPage> createState() => _PublishingPageState();
}

class _PublishingPageState extends State<PublishingPage> implements IRefresh{
  // Map<String, String> filterSelections = Map<String, String>();
  Map<String, List<String>> filterSelections = {};

  TextEditingController searchBar = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;

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

  // Widget createDropDownFromList(List<String> options, String fieldName) {
  //   setState(() {
  //     // filterSelections.putIfAbsent(fieldName, () => options.first);
  //     filterSelections.putIfAbsent(fieldName, () => <String>[]);
  //   });
  //   return Row(
  //     children: [
  //       Text(
  //         fieldName,
  //         style: TextStyle(
  //             fontSize: 15,
  //             fontWeight: FontWeight.bold
  //         ),
  //       ),
  //       SizedBox(width: 15,),
  //       Container(
  //         decoration: BoxDecoration(
  //             color: Theme.of(context).highlightColor,
  //             borderRadius: BorderRadius.circular(10)
  //         ),
  //         child: DropdownButton(
  //             value: filterSelections[fieldName],
  //             icon: const Icon(Icons.arrow_downward),
  //             elevation: 16,
  //             items: options.map<DropdownMenuItem<String>>((String value) {
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(value),
  //                 ),
  //               );
  //             }).toList(),
  //             onChanged: (String? value) {
  //               setState(() {
  //                 filterSelections[fieldName] = value!;
  //                 print(filterSelections.values);
  //               });
  //             }
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget createMultiSelectDropDownFromList(List<String> options, String fieldName) {
    // Initialize the filter for this field as an empty list if not already set.
    setState(() {
      filterSelections.putIfAbsent(fieldName, () => <String>[]);
    });
    return Row(
      children: [
        Text(
          fieldName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        // Using Expanded to allow the dropdown to take up available space.
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MultiSelectDialogField<String>(
              // Convert each option into a MultiSelectItem.
              items: options
                  .map((option) => MultiSelectItem<String>(option, option))
                  .toList(),
              title: Text(fieldName),
              // Display selected options as a comma-separated string.
              buttonText: Text(
                filterSelections[fieldName]!.isEmpty
                    ? 'Select $fieldName'
                    : filterSelections[fieldName]!.join(', '),
                overflow: TextOverflow.ellipsis,
              ),
              buttonIcon: const Icon(Icons.arrow_drop_down),
              listType: MultiSelectListType.CHIP, // Use CHIP or LIST based on your preference.
              onConfirm: (List<String> selectedValues) {
                setState(() {
                  filterSelections[fieldName] = selectedValues;
                  print('Selected for $fieldName: ${filterSelections[fieldName]}');
                });
              },
              // Optional: Customize the dialog or chip display if desired.
            ),
          ),
        ),
      ],
    );
  }

  // String getFiltersAsString() {
  //   bool noneSelected = true;
  //   int amountAdded = 0;
  //   String output = "";
  //   for (String s in filterSelections.values) {
  //     if (s != "All") {
  //       noneSelected = false;
  //       if (amountAdded >= 1) {
  //         output += ", ";
  //       }
  //       output += s;
  //       amountAdded++;
  //     }
  //   }
  //   return noneSelected? "No filters selected." : output;
  // }
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

  @override
  void onPageExited() {
    RefreshNotifier().removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = fieldsToUseAsFilters.first;
    int delayMilliSeconds =25;
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
                                  child: createMultiSelectDropDownFromList(courseLevelOptions, "Course Level"),
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
                                    child: createMultiSelectDropDownFromList(csTopicOptions, "CS Topics")
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
                                    child: createMultiSelectDropDownFromList(learningObjectiveOptions, "Learning Suggestions")
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
