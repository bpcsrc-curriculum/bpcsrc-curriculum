import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/classes/RefreshNotifier.dart';
import 'package:src_viewer/classes/SubmissionField.dart';

import '../misc.dart';

class LessonEntryModal extends StatelessWidget {
  LessonEntry entry;
  LessonEntryModal({super.key, required this.entry});
  List<String> info = fieldsToShowInTable;

  Widget displayTabularFields(BuildContext context) {
    List<DataRow> rows = [];
    int delayMilliSeconds = 75;
    int currentDelay = 0;
    for (String label in info) {
      SubmissionField sF = entry.getSubmissionField(label);

      rows.add(DataRow(cells: [
        DataCell(FadeInLeft(
            delay: Duration(milliseconds: currentDelay),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: JustTheTooltip(
                backgroundColor: const Color(0xFF333333),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    sF.desc,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ))),
        DataCell(FadeInLeft(
          delay: Duration(milliseconds: currentDelay),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: determineWidget(label, sF.value),
          ),
        ))
      ]));
      currentDelay += delayMilliSeconds;
    }

    return DataTable(
        dataRowMaxHeight: double.infinity,
        columns: const [
          DataColumn(
              label: Text(
            "Field",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          DataColumn(
              label: Text("Response",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))
        ],
        rows: rows);
  }

  Widget determineWidget(String field, String value) {
    if (value.isEmpty) {
      return const Text("No data provided.");
    }
    switch (field) {
      case "Student Samples":
      case "Instructor's Guide":
      case "File URL":
        List<String> URLs = value.split(",");
        List<Widget> downloadButtons = [];
        for (int i = 0; i < URLs.length; i++) {
          downloadButtons.add(ElevatedButton(
              onPressed: () {
                html.window.open(URLs[i], field);
              },
              child: Text("View Link ${i + 1}")));
        }
        return Column(
          children: downloadButtons,
        );
      default:
        return Text(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    String timestamp = entry.fields['Upload Date']?.value ?? '';
    DateTime dateTime;
    try {
      dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    } catch (e) {
      dateTime = DateTime.now(); // Fallback to current time if parsing fails
    }
    var formattedDate = DateFormat("MM/dd/yyyy HH:mm:ss").format(dateTime);

    return SelectionArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              entry.getSubmissionField("Activity").value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "submitted by ",
                ),
                Text(
                  entry.getSubmissionField("Contributor").value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  " (${entry.getSubmissionField("Contributor Email").value})",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const Text(" on "),
                Text(formattedDate)
              ],
            ),
            Text(
              "       ${entry.getSubmissionField("Description").value}",
              style: const TextStyle(fontSize: 15.5),
            ),
            displayTabularFields(context),
          ],
        ),
      ),
    );
  }
}

dynamic createLessonEntryModal(LessonEntry entry, BuildContext context) {
  return AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.noHeader,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: LessonEntryModal(entry: entry),
          ),
          btnCancelText: "Back",
          btnCancelColor: Colors.grey,
          btnCancelIcon: Icons.arrow_back,
          btnCancelOnPress: () {})
      .show()
      .then((value) {
    RefreshNotifier().notifyListeners();
  });
}
