import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/classes/Review.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/widgets/LessonEntryWidget.dart';
import 'package:src_viewer/misc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'dart:developer';

import '../classes/IRefresh.dart';
import '../classes/RefreshNotifier.dart';
import '../modals/PasswordEntryModal.dart';

/// A robust, reusable multi-select dropdown with overlay, fade animation, and 'Select All' support.
class StringMultiSelectDropDown extends StatefulWidget {
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
  State<StringMultiSelectDropDown> createState() => _StringMultiSelectDropDownState();
}

class _StringMultiSelectDropDownState extends State<StringMultiSelectDropDown> with SingleTickerProviderStateMixin {
  List<String> selectedItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isExpanded = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.initialSelected);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _fadeController.forward(from: 0);
    setState(() => isExpanded = true);
  }

  Future<void> _closeDropdown() async {
    await _fadeController.reverse();
    _removeOverlay();
    setState(() => isExpanded = false);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Only add 'All' if not present in options
    List<String> allOptions = widget.options.contains("All")
        ? List.from(widget.options)
        : ["All", ...widget.options];

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: allOptions.map((option) {
                            bool isAll = option == "All";
                            bool isSelected = isAll
                                ? selectedItems.length == widget.options.length
                                : selectedItems.contains(option);
                            return InkWell(
                              onTap: () {
                                // Remove and rebuild overlay for visual update
                                _removeOverlay();
                                setState(() {
                                  if (isAll) {
                                    if (selectedItems.length == widget.options.length) {
                                      selectedItems.clear();
                                    } else {
                                      selectedItems = List.from(widget.options);
                                    }
                                  } else {
                                    if (isSelected) {
                                      selectedItems.remove(option);
                                    } else {
                                      selectedItems.add(option);
                                    }
                                  }
                                });
                                widget.onChanged(List.from(selectedItems));
                                // Rebuild overlay to update checkboxes/colors
                                _overlayEntry = _createOverlayEntry();
                                Overlay.of(context).insert(_overlayEntry!);
                              },
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                      size: 22,
                                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap: () {
            if (isExpanded) {
              _closeDropdown();
            } else {
              _openDropdown();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty ? widget.hint : selectedItems.join(', '),
                    style: TextStyle(
                      color: selectedItems.isEmpty ? Colors.grey : Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> with SingleTickerProviderStateMixin implements IRefresh{
  // Map<String, String> filterSelections = Map<String, String>();
  Map<String, List<String>> filterSelections = {};
  TextEditingController searchBar = TextEditingController();
  var _animation;
  var _animationController;
  final db = FirebaseFirestore.instance;
  String sortOption = 'newest'; // 'newest', 'mostReviews'

  // This returns every approved lesson in firebase
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> fetchSubmissions() async {
    return (
        await db.collection("submissions")
        .where("Approved", isEqualTo: "APPROVED")
        .get()
    ).docs;
  }

  // original normal dropdown
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
  //           fontSize: 15,
  //           fontWeight: FontWeight.bold
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

  // pop up multi select dropdown
  // Widget createMultiSelectDropDownFromList(List<String> options, String fieldName) {
  //   // Initialize the filter for this field as an empty list if not already set.
  //   setState(() {
  //     filterSelections.putIfAbsent(fieldName, () => <String>[]);
  //   });
  //   return Row(
  //     children: [
  //       Text(
  //         fieldName,
  //         style: const TextStyle(
  //           fontSize: 15,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(width: 15),
  //       // Using Expanded to allow the dropdown to take up available space.
  //       Expanded(
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).highlightColor,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: MultiSelectDialogField<String>(
  //             // Convert each option into a MultiSelectItem.
  //             items: options
  //                 .map((option) => MultiSelectItem<String>(option, option))
  //                 .toList(),
  //             title: Text(fieldName),
  //             // Display selected options as a comma-separated string.
  //             buttonText: Text(
  //               filterSelections[fieldName]!.isEmpty
  //                   ? 'Select $fieldName'
  //                   : filterSelections[fieldName]!.join(', '),
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             buttonIcon: const Icon(Icons.arrow_drop_down),
  //             listType: MultiSelectListType.CHIP, // Use CHIP or LIST based on your preference.
  //             onConfirm: (List<String> selectedValues) {
  //               setState(() {
  //                 filterSelections[fieldName] = selectedValues;
  //                 print('Selected for $fieldName: ${filterSelections[fieldName]}');
  //               });
  //             },
  //             // Optional: Customize the dialog or chip display if desired.
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }


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
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 25;
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
                child: ClipRect(
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
                              setState(() {});
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
                              child: StringMultiSelectDropDown(
                                options: courseLevelOptions,
                                initialSelected:
                                    filterSelections["Course Level"] ?? [],
                                hint: "Select Course Level",
                                displayNameMap: courseLevelDisplayNames,
                                onChanged: (selected) {
                                  filterSelections["Course Level"] = selected;
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
                                  filterSelections["Campus"] =
                                      selected;
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
                          var reviews = a.fields['Reviews']!.value as List;
                          // Count only approved reviews
                          aReviews = reviews
                              .map((reviewMap) => Review.fromMap(reviewMap))
                              .where((review) => review.Approved.toUpperCase() == "APPROVED")
                              .length;
                        } else if (a.fields.containsKey('Reviews')) {
                          try {
                            var reviews = a.fields['Reviews']!.value as List<dynamic>;
                            // Count only approved reviews
                            aReviews = reviews
                                .map((reviewMap) => Review.fromMap(reviewMap))
                                .where((review) => review.Approved.toUpperCase() == "APPROVED")
                                .length;
                          } catch (_) {
                            aReviews = 0;
                          }
                        }
                        if (b.fields.containsKey('Reviews') && b.fields['Reviews']!.value is List) {
                          var reviews = b.fields['Reviews']!.value as List;
                          // Count only approved reviews
                          bReviews = reviews
                              .map((reviewMap) => Review.fromMap(reviewMap))
                              .where((review) => review.Approved.toUpperCase() == "APPROVED")
                              .length;
                        } else if (b.fields.containsKey('Reviews')) {
                          try {
                            var reviews = b.fields['Reviews']!.value as List<dynamic>;
                            // Count only approved reviews
                            bReviews = reviews
                                .map((reviewMap) => Review.fromMap(reviewMap))
                                .where((review) => review.Approved.toUpperCase() == "APPROVED")
                                .length;
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

            // Floating action menu item
            Bubble(
            title:"Refresh Data",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).primaryColor,
            icon:Icons.refresh,
            titleStyle:const TextStyle(fontSize: 16 , color: Colors.white),
              onPress: () {
                _animationController.reverse();
                // Use Future.microtask to defer setState until after animation
                Future.microtask(() {
                  if (mounted) {
                    setState(() {});
                  }
                });
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
        ),
      ),
    );
  }
}
