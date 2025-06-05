class Review {
  final String reviewerEmail;
  final String timestamp;
  final String contributorCampus;
  final String review;
  final String reviewerRole;
  final String reviewerName;
  final String courseCodeAndTitle;

  Review({
    required this.reviewerEmail,
    required this.timestamp,
    required this.contributorCampus,
    required this.review,
    required this.reviewerRole,
    required this.reviewerName,
    required this.courseCodeAndTitle,
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
    );
  }

  static List<Review> getTestReviews() {
    return [
      Review(
        reviewerEmail: "prof.smith@csula.edu",
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        contributorCampus: "California State University, Los Angeles",
        review:
            "This is an excellent assignment that effectively teaches students about social responsibility in computing. The real-world examples and hands-on activities make the concepts very engaging.",
        reviewerRole: "Professor",
        reviewerName: "Dr. Smith",
        courseCodeAndTitle: "CS101 - Introduction to Programming",
      ),
      Review(
        reviewerEmail: "ta.johnson@csula.edu",
        timestamp: (DateTime.now().millisecondsSinceEpoch - 86400000)
            .toString(), // 1 day ago
        contributorCampus: "California State University, Los Angeles",
        review:
            "I've used this assignment in my lab sections and students really enjoyed the practical approach. The discussion questions sparked great conversations about ethics in technology.",
        reviewerRole: "Teaching Assistant",
        reviewerName: "Sarah Johnson",
        courseCodeAndTitle: "CS101 - Introduction to Programming",
      ),
      Review(
        reviewerEmail: "student.wilson@csula.edu",
        timestamp: (DateTime.now().millisecondsSinceEpoch - 172800000)
            .toString(), // 2 days ago
        contributorCampus: "California State University, Los Angeles",
        review:
            "As a student, I found this assignment really eye-opening. It helped me understand how technology can impact different communities and the importance of considering diverse perspectives.",
        reviewerRole: "Student",
        reviewerName: "Michael Wilson",
        courseCodeAndTitle: "CS101 - Introduction to Programming",
      ),
    ];
  }
}
