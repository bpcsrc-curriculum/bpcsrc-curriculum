import 'package:src_viewer/classes/SubmissionField.dart';

String password = "SRCManagement!01";
String formFetchURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTv4rXDj1e1ZzFjVvLvVglwOjcB8VxbszsBwIboQMTCJZPMgEYGsjKt5OqGa6tDyZyFATMcvol7rCZH/pub?gid=2127720475&single=true&output=csv";
String formURL = "https://docs.google.com/forms/d/e/1FAIpQLSfAN2FaAys-0DZd4W-a8y5M3V8r32NY7zg9ms7pBsv8oWfFQg/viewform";
List<String> formFields = [
  "Approved",
  "Timestamp",
  "Activity Title",
  "Contributor Name",
  "Contributor (email)",
  "Description",
  "Type (Optional)",
  "Course Level",
  "Domain/Societal Factor",
  "Programming Language",
  "CS Topics",
  "Prerequisite Knowledge",
  "Learning Objectives",
  "Student Samples (Optional)",
  "Instructor's Guide (Optional)",
  "Issues and solutions (Optional)",
  "References for instructor (Optional)",
  "File Submission",
  "Has this assignment been used for a class before?"
];

Map<String, SubmissionField> generateFields(Map<String, dynamic> map) {
  return {
    "Approved": SubmissionField(value: map['Approved'], desc: "Whether or not this curriculum is approved to be viewed and downloaded."),
    "Upload Date": SubmissionField(value: map['Timestamp'].toString(), desc: 'The time that this assignment was uploaded.'),
    "Activity": SubmissionField(value: map['Activity Title'], desc: 'The name of the lesson.'),
    "Contributor": SubmissionField(value: map['Contributor Name'], desc: 'The name of the assignment creator.'),
    "Contributor Email": SubmissionField(value: map['Contributor (email)'], desc: 'The email address of the assignment creator.'),
    "Description": SubmissionField(value: map['Description'], desc: 'A short description of the concept covered and the tasks students will complete.'),
    "Type": SubmissionField(value: map['Type (Optional)'], desc: 'Whether this is an assignment or a project,'),
    "Course Level": SubmissionField(value: map['Course Level'], desc: 'The intended course for this assignment.'),
    "Domain/Societal Factor": SubmissionField(value: map['Domain/Societal Factor'], desc: 'The societal factor or domain related to this assignment.'),
    "Programming Language": SubmissionField(value: map['Programming Language'], desc: 'Programming languages that submissions are intended to be written in.'),
    "CS Topics": SubmissionField(value: map['CS Topics'], desc: 'A list of topics as covered by this assignment.'),
    "Prerequisite Knowledge": SubmissionField(value: map['Prerequisite Knowledge'], desc: 'A list of concepts students should already know so they can work on the assignment.'),
    "Learning Objectives": SubmissionField(value: map['Learning Objectives'], desc: 'A list of concepts students should know by the end of the assignment.'),
    "Student Samples": SubmissionField(value: map['Student Samples (Optional)'], desc: 'A URL of what a proper submission to this assignment should look like.'),
    "Instructor's Guide": SubmissionField(value: map["Instructor's Guide (Optional)"], desc: 'A link to a Google Drive document of any additional materials that instructors can use.'),
    "Issues and Solutions": SubmissionField(value: map['Issues and solutions (Optional)'], desc: 'A list of issues that instructors might experience while giving the assignment and possible solutions to address them.'),
    "References for Instructor": SubmissionField(value: map['References for instructor (Optional)'], desc: 'Any reference materials, readings, or answer keys that can help the instructor.'),
    "File URL": SubmissionField(value: map['File Submission'], desc: 'A link to a Google Drive document of the assignment for you to download.'),
    "Used Before": SubmissionField(value: map["Has this assignment been used for a class before?"], desc: "Has this assignment been used for a class before?"),
  };
}

List<String> fieldsToShowInTable = [
  "Type",
  "Course Level",
  "Domain/Societal Factor",
  "Programming Language",
  "CS Topics",
  "Prerequisite Knowledge",
  "Learning Objectives",
  "Used Before",
  "Issues and Solutions",
  "References for Instructor",
  "File URL",
  "Student Samples",
  "Instructor's Guide",
];

List<String> fieldsToShowInTableForPublishing = [
  "Type",
  "Course Level",
  "Domain/Societal Factor",
  "Programming Language",
  "CS Topics",
  "Prerequisite Knowledge",
  "Learning Objectives",
  "Used Before",
  "Issues and Solutions",
  "References for Instructor",
  "File URL",
  "Student Samples",
  "Instructor's Guide",
];

List<String> fieldsToUseAsFilters = [
  "All",
  "Course Level",
  "CS Topics",
  "Learning Objectives"
];