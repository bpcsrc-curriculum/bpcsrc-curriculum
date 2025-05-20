class Review {
  final String contributorEmail;
  final String assignmentTimestamp;
  final String campus;
  final String review;
  final String reviewerOccupation;
  final String reviewerName;

  Review({
    required this.contributorEmail,
    required this.assignmentTimestamp,
    required this.campus,
    required this.review,
    required this.reviewerOccupation,
    required this.reviewerName,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      contributorEmail: map['Contributor (email)'] ?? '',
      assignmentTimestamp: map['AssignmentTimestamp'] ?? '',
      campus: map['Campus'] ?? '',
      review: map['Review'] ?? '',
      reviewerOccupation: map['Reviewer Occupation'] ?? '',
      reviewerName: map['ReviewerName'] ?? '',
    );
  }

  static List<Review> getTestReviews() {
    return [
      Review(
        contributorEmail: "prof.smith@csula.edu",
        assignmentTimestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        campus: "California State University, Los Angeles",
        review:
            "This is an excellent assignment that effectively teaches students about social responsibility in computing. The real-world examples and hands-on activities make the concepts very engaging.",
        reviewerOccupation: "Professor",
        reviewerName: "Dr. Smith",
      ),
      Review(
        contributorEmail: "ta.johnson@csula.edu",
        assignmentTimestamp: (DateTime.now().millisecondsSinceEpoch - 86400000)
            .toString(), // 1 day ago
        campus: "California State University, Los Angeles",
        review:
            "I've used this assignment in my lab sections and students really enjoyed the practical approach. The discussion questions sparked great conversations about ethics in technology.",
        reviewerOccupation: "Teaching Assistant",
        reviewerName: "Sarah Johnson",
      ),
      Review(
        contributorEmail: "student.wilson@csula.edu",
        assignmentTimestamp: (DateTime.now().millisecondsSinceEpoch - 172800000)
            .toString(), // 2 days ago
        campus: "California State University, Los Angeles",
        review:
            "As a student, I found this assignment really eye-opening. It helped me understand how technology can impact different communities and the importance of considering diverse perspectives.",
        reviewerOccupation: "Student",
        reviewerName: "Michael Wilson",
      ),
    ];
  }
}
