import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/classes/Review.dart';
import 'dart:html' as html;

class ReviewModal extends StatelessWidget {
  final LessonEntry entry;
  final db = FirebaseFirestore.instance;

  ReviewModal({super.key, required this.entry});

  Widget displayReviewsTable(BuildContext context, List<Review> reviews) {
    List<DataRow> rows = [];
    int delayMilliSeconds = 75;
    int currentDelay = 0;

    for (Review review in reviews) {
      var dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(review.timestamp));
      var formattedDate = DateFormat("MM/dd/yyyy HH:mm:ss").format(dateTime);

      rows.add(DataRow(cells: [
        DataCell(
          FadeInLeft(
            delay: Duration(milliseconds: currentDelay),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    review.reviewerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${review.reviewerRole}, ${review.courseCodeAndTitle}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.contributorCampus,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          FadeInLeft(
            delay: Duration(milliseconds: currentDelay),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    review.review,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat("MM/dd/yyyy HH:mm:ss").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.tryParse(review.timestamp) ?? 0)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]));
      currentDelay += delayMilliSeconds;
    }

    return DataTable(
      dataRowMaxHeight: double.infinity,
      columnSpacing: 20,
      horizontalMargin: 10,
      columns: const [
        DataColumn(
          label: Expanded(
            child: Text(
              "Reviewer Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              "Review",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reviews for ${entry.getSubmissionField("Activity").value}",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                return StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection("submissions")
                      .where("Activity Title",
                          isEqualTo: entry.getSubmissionField("Activity").value)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error loading reviews"),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var doc = snapshot.data!.docs.first;
                    var reviews = (doc.data()
                        as Map<String, dynamic>)['Reviews'] as List<dynamic>?;

                    if (reviews == null || reviews.isEmpty) {
                      return const Center(
                        child: Text(
                          "No reviews available yet. Be the first to review this activity!",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    // Filter reviews to only show approved ones
                    var approvedReviews = reviews
                        .map((reviewMap) => Review.fromMap(reviewMap))
                        .where((review) =>
                            review.Approved.toUpperCase() == "APPROVED")
                        .toList();

                    if (approvedReviews.isEmpty) {
                      return const Center(
                        child: Text(
                          "No approved reviews available yet. Be the first to review this activity!",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: displayReviewsTable(
                          context,
                          approvedReviews,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open the form in a new tab
                      html.window.open(
                          'https://docs.google.com/forms/d/e/1FAIpQLSfwhndjvPnTOlKMWyH-EvRNhTzwPpLEhOySHA_4I_XdS8UX9w/viewform?usp=pp_url&entry.877086558=${Uri.encodeComponent(entry.getSubmissionField("Activity").value)}', '_blank');
                    },
                    icon: const Icon(Icons.add_comment),
                    label: const Text("Add Review"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  )
                  // const SizedBox(width: 16),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     // Open the form in a new tab
                  //     html.window.open(
                  //         'https://forms.gle/QB76gBdPAn6H3dEr8', '_blank');
                  //   },
                  //   icon: const Icon(Icons.open_in_new),
                  //   label: const Text("Submit Review Form"),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

dynamic createReviewModal(LessonEntry entry, BuildContext context) {
  return AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.noHeader,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ReviewModal(entry: entry),
          ),
          btnCancelText: "Back",
          btnCancelColor: Colors.grey,
          btnCancelIcon: Icons.arrow_back,
          btnCancelOnPress: () {})
      .show();
}
