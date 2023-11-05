import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/classes/RefreshNotifier.dart';

import '../misc.dart';
import 'LessonEntryModal.dart';

class LessonApprovalModal extends LessonEntryModal {
  var docRef;
  LessonApprovalModal({super.key, required super.entry, required this.docRef});

  List<String> info = fieldsToShowInTableForPublishing;

  @override
  Widget determineWidget(String field, String value){
    if (value.isEmpty) {
      return Text("No data provided.");
    }
    switch (field) {
      case "Student Samples":
      case "Instructor's Guide":
      case "File URL":
        return ElevatedButton(
            onPressed: () {
              String url = value;
              html.window.open(url, field);
            },
            child: Text("View Here")
        );
      default:
        return Text(value);
    }
  }
}

dynamic createLessonApprovalModal(LessonEntry entry, DocumentReference docRef, BuildContext context) {
  bool approved = entry.getSubmissionField("Approved").value == "APPROVED";

  return AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      dialogType: DialogType.noHeader,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: LessonApprovalModal(entry: entry, docRef: docRef,),
      ),
      btnOkText: approved? "Delist" : "Approve",
      btnOkIcon: approved? Icons.close : Icons.check,
      btnOkColor: approved? Colors.red : Colors.green,
      btnOkOnPress: () async {
        String status = approved? "" : "APPROVED";

        await docRef.update(
            {"Approved": status}
        ).then((value) {
          showConfirmationMessage(context, approved? "Delist":"Approval");
        });
      },
      btnCancelText: "Back",
      btnCancelColor: Colors.grey,
      btnCancelIcon: Icons.arrow_back,
      btnCancelOnPress: () {
      }
  ).show();
}

void showConfirmationMessage(BuildContext context, String operationName) {
  AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      dialogType: DialogType.success,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SelectionArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("${operationName} Confirmed!"),
                Text("Your change has been successfully processed."),
              ],
            ),
          ),
        ),
      ),
      btnCancelText: "Back",
      btnCancelColor: Colors.grey,
      btnCancelIcon: Icons.arrow_back,
      btnCancelOnPress: () {
      }
  ).show().then((value) {
    RefreshNotifier().notifyListeners();
  });
}