import 'package:src_viewer/classes/SubmissionField.dart';

String password = "SRCManagement!01";
String formFetchURL =
    "https://docs.google.com/spreadsheets/d/e/2PACX-1vTv4rXDj1e1ZzFjVvLvVglwOjcB8VxbszsBwIboQMTCJZPMgEYGsjKt5OqGa6tDyZyFATMcvol7rCZH/pub?gid=2127720475&single=true&output=csv";
String formURL =
    "https://docs.google.com/forms/d/e/1FAIpQLSfAN2FaAys-0DZd4W-a8y5M3V8r32NY7zg9ms7pBsv8oWfFQg/viewform";
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
  "Has this assignment been used for a class before?",
  "Contributor Campus"
];

// Map of all key:value pairs in database, update with data as needed.
Map<String, SubmissionField> generateFields(Map<String, dynamic> map) {

  /*
  for (var key in map.keys) {
    print('"$key"');
  }

  print('Contributor Campus: ${map["Contributor Campus"]}');
  */

  return {
    "Approved": SubmissionField(
        value: map['Approved']?.toString() ?? '',
        desc:
            "Whether or not this curriculum is approved to be viewed and downloaded."),
    "Upload Date": SubmissionField(
        value: map['Timestamp']?.toString() ?? '',
        desc: 'The time that this assignment was uploaded.'),
    "Activity": SubmissionField(
        value: map['Activity Title']?.toString() ?? '',
        desc: 'The name of the lesson.'),
    "Contributor": SubmissionField(
        value: map['Contributor Name']?.toString() ?? '',
        desc: 'The name of the assignment creator.'),
    "Contributor Email": SubmissionField(
        value: map['Contributor (email)']?.toString() ?? '',
        desc: 'The email address of the assignment creator.'),
    "Description": SubmissionField(
        value: map['Description']?.toString() ?? '',
        desc:
            'A short description of the concept covered and the tasks students will complete.'),
    "Type": SubmissionField(
        value: map['Type (Optional)']?.toString() ?? '',
        desc: 'Whether this is an assignment or a project,'),
    "Course Level": SubmissionField(
        value: map['Course Level']?.toString() ?? '',
        desc: 'The intended course for this assignment.'),
    "Domain/Societal Factor": SubmissionField(
        value: map['Domain/Societal Factor']?.toString() ?? '',
        desc: 'The societal factor or domain related to this assignment.'),
    "Programming Language": SubmissionField(
        value: map['Programming Language']?.toString() ?? '',
        desc:
            'Programming languages that submissions are intended to be written in.'),
    "CS Topics": SubmissionField(
        value: map['CS Topics']?.toString() ?? '',
        desc: 'A list of topics as covered by this assignment.'),
    "Prerequisite Knowledge": SubmissionField(
        value: map['Prerequisite Knowledge']?.toString() ?? '',
        desc:
            'A list of concepts students should already know so they can work on the assignment.'),
    "Learning Objectives": SubmissionField(
        value: map['Learning Objectives']?.toString() ?? '',
        desc:
            'A list of concepts students should know by the end of the assignment.'),
    "Student Samples": SubmissionField(
        value: map['Student Samples (Optional)']?.toString() ?? '',
        desc:
            'A URL of what a proper submission to this assignment should look like.'),
    "Instructor's Guide": SubmissionField(
        value: map["Instructor's Guide (Optional)"]?.toString() ?? '',
        desc:
            'A link to a Google Drive document of any additional materials that instructors can use.'),
    "Issues and Solutions": SubmissionField(
        value: map['Issues and solutions (Optional)']?.toString() ?? '',
        desc:
            'A list of issues that instructors might experience while giving the assignment and possible solutions to address them.'),
    "References for Instructor": SubmissionField(
        value: map['References for instructor (Optional)']?.toString() ?? '',
        desc:
            'Any reference materials, readings, or answer keys that can help the instructor.'),
    "File URL": SubmissionField(
        value: map['File Submission']?.toString() ?? '',
        desc:
            'A link to a Google Drive document of the assignment for you to download.'),
    "Used Before": SubmissionField(
        value: map["Has this assignment been used for a class before?"]
                ?.toString() ??
            '',
        desc: "Has this assignment been used for a class before?"),
    "Campus": SubmissionField(
          // The check is here as some data that could be approved in the future-
          // does not have a campus assigned
          value: map['Contributor Campus']?.toString() ?? "N/A",
          desc: 'The name of the contributor campus.',
        ),
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
  "Campus",
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
  "Campus",
];

List<String> fieldsToUseAsFilters = [
  "Course Level",
  "CS Topics",
  "Learning Objectives"
];

List<String> courseLevelOptions = [
  "All",
  "CS0 - Introduction of Computing",
  "CS1 - Introduction to Programming",
  "CS2 - Advanced Programming computing"
];

List<String> csTopicOptions = [
  "All",
  "Variables",
  "Data Types",
  "Control Structures",
  "Loops",
  "Functions",
  "Arrays",
  "Objects",
  "Strings",
  "Implementing Classes",
  "Inheritance",
  "Interfaces",
  "File I/O",
  "Lists",
  "Dictionaries",
  "Stacks",
  "Queues",
  "Trees",
  "Algorithmic Analysis",
  "Recursion"
];

List<String> learningObjectiveOptions = [
  "All",
  "L1 - Reducing Bias and Equity",
  "L2 - Maximizing Benefits to Society",
  "L3 - Evaluation of Socioeconomic Practices",
  "L4 - Seeking Diverse Perspectives",
  "L5 - Addressing Accessibility and User Needs",
  "L6 - Inclusion of Community Groups",
  "L7 - Reaching Communal Goals"
];

List<String> srcTopicsOptions = [
  "All",
  "Algorithmic bias and fairness",
  "Algorithmic transparency and accountability",
  "Healthcare",
  "Environmental Science and Sustainability",
  "Finance and Banking",
  "Responsible AI",
  "Education",
  "Accessibility",
  "Politics",
  "Economics and Equity",
  "Housing"
];
// Add below to a list on slides
List<String> collaboratorOptions = [
  "All",
  "SFSU",
  "CalStateLA",
  "CPP",
  "Cal Poly",
  "Fullerton",
  "CSUDH"
];
