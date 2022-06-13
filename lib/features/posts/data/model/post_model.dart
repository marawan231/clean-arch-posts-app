import 'package:clean_architecture_posts_app/features/posts/domain/entites/post.dart';
import 'package:flutter/foundation.dart';

class PostModel extends Post {
  const PostModel(
      {required int id, required String title, required String body})
      : super(
          id: id,
          title: title,
          body: body,
        );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
