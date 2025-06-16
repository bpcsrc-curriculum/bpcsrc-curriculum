import 'package:src_viewer/classes/SubmissionField.dart';

import '../misc.dart';

class LessonEntry {
  Map<String, SubmissionField> fields = {};

  LessonEntry() {
    //nothing happens here
  }

  bool queryAll(String query) {
    String combined = "";
    for (SubmissionField sF in fields.values) {
      combined += sF.value;
    }
    return combined.toLowerCase().contains(query.toLowerCase());
  }

  // bool queryFieldMap(Map<String, String> fieldMap) {
  //   for (String field in fieldMap.keys) {
  //     if (fieldMap[field] == "All") {
  //       continue;
  //     }
  //     if (!queryField(fieldMap[field]!, field)) {
  //       print("Not found");
  //       return false;
  //     }
  //   }
  //   return true;
  // }
  //
  // bool queryField(String query, String field) {
  //   return getSubmissionField(field).value.toLowerCase().contains(query.toLowerCase());
  // }
  //

  bool queryFieldMap(Map<String, List<String>> fieldMap) {
    for (String field in fieldMap.keys) {
      List<String> selectedQueries = fieldMap[field]!;

      // If "All" is selected or no filter is applied, skip filtering for this field.
      if (selectedQueries.contains("All") || selectedQueries.isEmpty) {
        continue;
      }

      // Check if at least one selected query is found in the submission field.
      bool anyMatch = selectedQueries.any((query) => queryField(query, field));
      if (!anyMatch) {
        print("Not found for field: $field");
        return false;
      }
    }
    return true;
  }

  bool queryField(String query, String field) {
    // Use contains matching for all fields
    return getSubmissionField(field)
        .value
        .toLowerCase()
        .contains(query.toLowerCase());
  }

  SubmissionField getSubmissionField(String field) {
    if (fields.containsKey(field)) {
      return fields[field]!;
    } else {
      return SubmissionField(value: "ERROR_VALUE", desc: "ERROR_DESC");
    }
  }

  factory LessonEntry.fromMap(Map<String, dynamic> map) {
    LessonEntry output = LessonEntry();
    output.fields = generateFields(map);
    return output;
  }
}