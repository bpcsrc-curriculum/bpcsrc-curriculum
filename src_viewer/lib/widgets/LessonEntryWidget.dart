import 'package:animate_do/animate_do.dart';
import 'package:animate_on_hover/animate_on_hover.dart';
import 'package:flutter/material.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../modals/LessonEntryModal.dart';
import '../modals/ReviewModal.dart';

class LessonEntryWidget extends StatelessWidget {
  LessonEntry entry;
  LessonEntryWidget({super.key, required this.entry});
  int currentDelay = 0;

  int increaseCurrentDelay(int byMilliSeconds) {
    return currentDelay += byMilliSeconds;
  }

  Widget getFadeInDelayWidget(int delay, Widget child) {
    return FadeIn(
        delay: Duration(milliseconds: increaseCurrentDelay(delay)),
        child: child);
  }

  void onWidgetTapped(LessonEntry entry, BuildContext context) {
    createLessonEntryModal(entry, context);
  }

  String shrinkLearningObjectiveString(String learningObjectives) {
    List<String> objectiveList = learningObjectives.split(",");
    String output = "";
    for (int i = 0; i < objectiveList.length; i++) {
      output += objectiveList[i].replaceAll(" ", "").substring(0, 2);
      if (i < objectiveList.length - 1) {
        output += ", ";
      }
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 200;

    return InkWell(
      onTap: () {
        onWidgetTapped(entry, context);
      },
      child: Card(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getFadeInDelayWidget(
                    delayMilliSeconds,
                    Text(
                      entry.getSubmissionField("Activity").value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 25),
                    ),
                  ),
                  Row(
                    children: [
                      getFadeInDelayWidget(
                        delayMilliSeconds,
                        Text(
                          entry.getSubmissionField("Contributor").value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox.fromSize(
                        size: const Size(15, 15),
                        child: const SizedBox.shrink(),
                      ),
                      getFadeInDelayWidget(
                        delayMilliSeconds,
                        Text(
                          "(${entry.getSubmissionField("Contributor Email").value})",
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      getFadeInDelayWidget(
                        delayMilliSeconds,
                        Row(
                          children: [
                            const Text(
                              "A ",
                            ),
                            Text(
                              "${entry.getSubmissionField("Programming Language").value} ",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(entry
                                .getSubmissionField("Type")
                                .value
                                .toLowerCase()),
                          ],
                        ),
                      ),
                      getFadeInDelayWidget(
                        delayMilliSeconds,
                        Row(
                          children: [
                            const Text(
                              " for ",
                            ),
                            Text(
                              entry.getSubmissionField("Course Level").value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      getFadeInDelayWidget(
                        delayMilliSeconds,
                        Row(
                          children: [
                            const Text(
                              " covering ",
                            ),
                            Text(
                              shrinkLearningObjectiveString(entry
                                  .getSubmissionField("Learning Objectives")
                                  .value),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox.fromSize(
                    size: const Size(15, 15),
                    child: const SizedBox.shrink(),
                  ),
                  getFadeInDelayWidget(
                      delayMilliSeconds,
                      IgnorePointer(
                          child: Text(
                              '          ${entry.getSubmissionField("Description").value}',
                              style: const TextStyle(fontSize: 15.5))))
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("submissions")
                    .where("Activity Title",
                        isEqualTo: entry.getSubmissionField("Activity").value)
                    .snapshots(),
                builder: (context, snapshot) {
                  int reviewCount = 0;
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    var doc = snapshot.data!.docs.first;
                    var reviews = (doc.data()
                        as Map<String, dynamic>)['Reviews'] as List<dynamic>?;
                    reviewCount = reviews?.length ?? 0;
                  }
                  if (reviewCount == 0) {
                    reviewCount = 3; // Show test reviews count
                  }
                  return IconButton(
                    icon: const Icon(Icons.rate_review_outlined, size: 28),
                    iconSize: 28,
                    onPressed: () {
                      createReviewModal(entry, context);
                    },
                    tooltip:
                        '$reviewCount Review${reviewCount == 1 ? '' : 's'}',
                  );
                },
              ),
            ),
          ],
        ),
      ).increaseSizeOnHover(1.03, duration: const Duration(milliseconds: 150)),
    );
  }
}
