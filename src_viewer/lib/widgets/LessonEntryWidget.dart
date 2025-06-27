import 'package:animate_do/animate_do.dart';
import 'package:animate_on_hover/animate_on_hover.dart';
import 'package:flutter/material.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:src_viewer/classes/Review.dart';

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
    if (learningObjectives.isEmpty) return '';
    List<String> objectiveList = learningObjectives.split(",");
    String output = "";
    for (int i = 0; i < objectiveList.length; i++) {
      String objective = objectiveList[i].trim();
      if (objective.length >= 2) {
        output += objective.substring(0, 2);
      } else if (objective.isNotEmpty) {
        output += objective;
      }
      if (i < objectiveList.length - 1) {
        output += ", ";
      }
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 50;

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

                    if (reviews != null) {
                      // Count only approved reviews
                      reviewCount = reviews
                          .map((reviewMap) => Review.fromMap(reviewMap))
                          .where((review) =>
                              review.Approved.toUpperCase() == "APPROVED")
                          .length;
                    }
                  }
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message:
                          '$reviewCount Review${reviewCount == 1 ? '' : 's'} - Click to view details',
                      child: InkWell(
                        onTap: () {
                          createReviewModal(entry, context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconData(0xf2ea, fontFamily: 'MaterialIcons'),
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$reviewCount",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Reviews",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
