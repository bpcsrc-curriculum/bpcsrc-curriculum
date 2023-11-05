import 'package:src_viewer/classes/SubmissionField.dart';

import '../misc.dart';

class LessonEntry {
  Map<String, SubmissionField> fields = {};

  LessonEntry() {
    //nothing happens here
  }

  bool matchesQuery(String query, String field) {
    if (field == "All") {
      String combined = "";
      for (SubmissionField sF in fields.values) {
        combined += sF.value;
      }
      return combined.toLowerCase().contains(query.toLowerCase());
    } else {
      return getSubmissionField(field).value.toLowerCase().contains(query.toLowerCase());
    }
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