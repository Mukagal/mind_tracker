class Insight {
  final int id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String? url;
  final String? fullContent;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.url,
    this.fullContent,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      date: json['date'],
      url: json['url'],
      fullContent: json['full_content'] ?? json['fullContent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'url': url,
      'fullContent': fullContent,
    };
  }
}
