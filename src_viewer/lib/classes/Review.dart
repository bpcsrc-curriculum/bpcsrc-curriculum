class Review {
  final String reviewerEmail;
  final String timestamp;
  final String contributorCampus;
  final String review;
  final String reviewerRole;
  final String reviewerName;
  final String courseCodeAndTitle;
  final String Approved;

  Review({
    required this.reviewerEmail,
    required this.timestamp,
    required this.contributorCampus,
    required this.review,
    required this.reviewerRole,
    required this.reviewerName,
    required this.courseCodeAndTitle,
    required this.Approved,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewerEmail: map['Reviewer Email'] ?? '',
      timestamp: map['Timestamp']?.toString() ?? '',
      contributorCampus: map['Contributor Campus'] ?? '',
      review: map['Review'] ?? '',
      reviewerRole: map['Reviewer Role'] ?? '',
      reviewerName: map['Reviewer Name'] ?? '',
      courseCodeAndTitle:
          map['Course Code and Title (e.g., CS101 - Introduction to Programming)'] ??
              '',
      Approved: map['Approved'] ?? '',
    );
  }
}
