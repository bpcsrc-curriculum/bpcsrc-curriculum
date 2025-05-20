import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/classes/Review.dart';

class ReviewModal extends StatelessWidget {
  final LessonEntry entry;
  final db = FirebaseFirestore.instance;

  ReviewModal({super.key, required this.entry});

  Widget displayReviewsTable(BuildContext context, List<Review> reviews) {
    List<DataRow> rows = [];
    int delayMilliSeconds = 75;
    int currentDelay = 0;

    for (Review review in reviews) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(review.assignmentTimestamp));
      var formattedDate = DateFormat("MM/dd/yyyy HH:mm:ss").format(dateTime);

      rows.add(DataRow(cells: [
        DataCell(
          FadeInLeft(
            delay: Duration(milliseconds: currentDelay),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.contributorEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${review.reviewerOccupation} at ${review.campus}",
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
                children: [
                  Text(
                    review.review,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
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
      columns: const [
        DataColumn(
          label: Text(
            "Reviewer Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataColumn(
          label: Text(
            "Review",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            StreamBuilder<QuerySnapshot>(
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
                var reviews = (doc.data() as Map<String, dynamic>)['Reviews']
                    as List<dynamic>?;

                if (reviews == null || reviews.isEmpty) {
                  return displayReviewsTable(context, Review.getTestReviews());
                }

                return displayReviewsTable(
                  context,
                  reviews
                      .map((reviewMap) => Review.fromMap(reviewMap))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add review functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add review functionality coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_comment),
                label: const Text("Add Review"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
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
