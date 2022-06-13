import 'package:clean_architecture_posts_app/core/erorrs/exceptions.dart';
import 'package:clean_architecture_posts_app/features/posts/data/datasources/post_remote_data_surce.dart';
import 'package:clean_architecture_posts_app/features/posts/data/model/post_model.dart';
import 'package:clean_architecture_posts_app/features/posts/domain/entites/post.dart';
import 'package:clean_architecture_posts_app/core/erorrs/failure.dart';
import 'package:clean_architecture_posts_app/features/posts/domain/repositories/posts_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../datasources/post_local_data_source.dart';

typedef Future<Unit> addOrUpdateOrDelete();

class PostRepositroyImplement implements PostsRepository {
  final PostsRemoteDataSource postsRemoteDataSource;
  final PostLocalDataSource postsLocalDataSource;
  final InternetConnectionChecker internetConnectionChecker;

  PostRepositroyImplement({
    required this.postsRemoteDataSource,
    required this.postsLocalDataSource,
    required this.internetConnectionChecker,
  });

  @override
  Future<Either<Failure, List<Post>>> getAllPosts() async {
    if (await internetConnectionChecker.hasConnection) {
      try {
        final remotePosts = await postsRemoteDataSource.getAllPosts();
        postsLocalDataSource.cachePosts(remotePosts);
        return Right(remotePosts);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedPosts = await postsLocalDataSource.getCachedPosts();
        return Right(cachedPosts);
      } on EmptyCacheException {
        return Left(EmptyCacheFaliure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> addPost(Post post) async {
    final PostModel postModel = PostModel(
      id: post.id,
      title: post.title,
      body: post.body,
    );
    return await _getMessge(() => postsRemoteDataSource.addPost(postModel));
  }

  @override
  Future<Either<Failure, Unit>> deletePost(int postId) async {
    return await _getMessge(() => postsRemoteDataSource.deletePost(postId));
  }

  @override
  Future<Either<Failure, Unit>> updatePost(Post post) async {
    final PostModel postModel = PostModel(
      id: post.id,
      title: post.title,
      body: post.body,
    );
    return await _getMessge(() => postsRemoteDataSource.updatePost(postModel));
  }

  Future<Either<Failure, Unit>> _getMessge(
    addOrUpdateOrDelete addOrDeleteOrUpdate,
  ) async {
    if (await internetConnectionChecker.hasConnection) {
      try {
        await addOrDeleteOrUpdate();
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
