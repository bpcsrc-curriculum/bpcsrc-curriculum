import 'package:animate_do/animate_do.dart';
import 'package:animate_on_hover/animate_on_hover.dart';
import 'package:flutter/material.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'dart:html' as html;

import '../modals/LessonEntryModal.dart';

class LessonEntryWidget extends StatelessWidget {
  LessonEntry entry;
  LessonEntryWidget({super.key, required this.entry});
  int currentDelay = 0;

  int increaseCurrentDelay(int byMilliSeconds) {
    return currentDelay+=byMilliSeconds;
  }

  Widget getFadeInDelayWidget(int delay, Widget child) {
    return FadeIn(
        delay: Duration(milliseconds: increaseCurrentDelay(delay)),
        child: child
    );
  }

  void onWidgetTapped(LessonEntry entry, BuildContext context) {
    createLessonEntryModal(entry, context);
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 200;

    return InkWell(
      onTap: () {
        onWidgetTapped(entry, context);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Activity").value,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25
                        ),
                      ),
                    ),
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Contributor").value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Contributor Email").value,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.fromSize(
                size: const Size(15, 15),
                child: const SizedBox.shrink(),
              ),
              Expanded(
                flex: 90,
                child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    IgnorePointer(
                      child: Text(
                          '          ${entry.getSubmissionField("Description").value}',
                          style: TextStyle(fontSize: 15.5)
                      )
                    )
                ),
              )
            ],
          ),
        ),
      ).increaseSizeOnHover(1.03, duration: const Duration(milliseconds: 150)),
    );
  }
}