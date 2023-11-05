import 'package:animate_on_hover/animate_on_hover.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:src_viewer/modals/LessonApprovalModal.dart';
import 'package:src_viewer/widgets/LessonEntryWidget.dart';
import '../classes/LessonEntry.dart';

class LessonApprovalWidget extends LessonEntryWidget {
  var docRef;
  LessonApprovalWidget({super.key, required super.entry, required this.docRef});

  @override
  void onWidgetTapped(LessonEntry entry, BuildContext context) {
    createLessonApprovalModal(entry, docRef, context);
  }

  Color determineColor() {
    switch(entry.getSubmissionField("Approved").value) {
      case "APPROVED":
        return const Color(0xFFC4F5A0);
      case "DENIED":
        return const Color(0xFFEC9090);
      default:
        return const Color(0xFFB4B4B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 200;
    var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(entry.fields['Upload Date']!.value));
    var formattedDate = DateFormat("MM/dd/yyyy HH:mm:ss").format(dateTime);

    return InkWell(
      onTap: () {
        onWidgetTapped(entry, context);
      },
      child: Card(
        color: determineColor(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 25,
                child: Center(
                  child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    JustTheTooltip(
                      backgroundColor: Color(0xFF333333),
                      content: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          entry.getSubmissionField("Activity").value,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                      child: Text(
                        entry.getSubmissionField("Activity").value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Center(
                  child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    JustTheTooltip(
                      backgroundColor: Color(0xFF333333),
                      content: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          entry.getSubmissionField("Contributor").value,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                      child: Text(
                        entry.getSubmissionField("Contributor").value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Center(
                  child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    JustTheTooltip(
                      backgroundColor: Color(0xFF333333),
                      content: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          entry.getSubmissionField("Contributor Email").value,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                      child: Text(
                        entry.getSubmissionField("Contributor Email").value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Center(
                  child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    JustTheTooltip(
                      backgroundColor: Color(0xFF333333),
                      content: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                      child: Text(
                        formattedDate,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).increaseSizeOnHover(1.03, duration: const Duration(milliseconds: 150)),
    );
  }
}
