import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../firebase/upload_image.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/post_repository.dart';
import '../../domain/post_data_model.dart';
part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc() : super(PostsInitial()) {
    on<PostChooseImageButtonClickedEvent>(postChooseImageButtonClickedEvent);
    on<PostImageChoosenSuccessEvent>(postImageChoosenSuccessEvent);
    on<PostUploadButtonClickedEvent>(postUploadButtonClickedEvent);
    on<PostUpdateButtonClickedEvent>(postUpdateButtonClickedEvent);
    on<PostLikeButtonClickedEvent>(postLikeButtonClickedEvent);
    on<PostSaveButtonClickedEvent>(postSaveButtonClickedEvent);
    on<PostNavigateToLikeScreenButtonClickedEvent>(
        postNavigateToLikeScreenButtonClickedEvent);
    on<PostNavigateToCommentScreenButtonClickedEvent>(
        postNavigateToCommentScreenButtonClickedEvent);
    on<PostAddCommentButtonClickedEvent>(postAddCommentButtonClickedEvent);
    on<PostShowAllPostOptionsButtonClickedEvent>(
        postShowAllPostOptionsButtonClickedEvent);
    on<PostHideAllPostOptionsButtonClickedEvent>(
        postHideAllPostOptionsButtonClickedEvent);
    on<PostShowAllCommentOptionsButtonClickedEvent>(
        postShowAllCommentOptionsButtonClickedEvent);
    on<PostHideAllCommentOptionsButtonClickedEvent>(
        postHideAllCommentOptionsButtonClickedEvent);
    on<PostEditPostButtonClickedEvent>(postEditPostButtonClickedEvent);
    on<PostDeletePostButtonClickedEvent>(postDeletePostButtonClickedEvent);
    on<PostDeleteConfirmationEvent>(postDeleteConfirmationEvent);
  }

  FutureOr<void> postChooseImageButtonClickedEvent(
    PostChooseImageButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostChooseUploadOptionActionState(
      isChangingImage: event.isChagingImage,
    ));
  }

  FutureOr<void> postImageChoosenSuccessEvent(
    PostImageChoosenSuccessEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostChoosenSuccessActionState(choosenImage: event.pickedImage));
  }

  FutureOr<void> postUploadButtonClickedEvent(
    PostUploadButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(PostUploadingActionState());
    final postId = const Uuid().v1();
    final String postUrl = await uploadImage(
      postImage: event.image,
      postId: postId,
      ref: 'user_posts',
    );
    final postInfo = PostDataModel(
      postId: postId,
      userId: AuthRepository.currentUser!.uid,
      username: AuthRepository.currentUser!.username,
      userImage: AuthRepository.currentUser!.userImage,
      caption: event.caption,
      postUrl: postUrl,
      postedOn: DateTime.now(),
      likes: [],
      calories: event.calories, // Yeni parametre eklendi
    );
    bool isUploadingSuccess = await PostRepository.uploadPost(
      postInfo: postInfo,
      postImage: event.image,
    );
    if (isUploadingSuccess) {
      emit(PostUploadSuccessActionState());
    } else {
      emit(PostUploadFailedActionState());
    }
  }

  FutureOr<void> postUpdateButtonClickedEvent(
    PostUpdateButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(PostUploadingActionState());
    final postInfo = event.postDataModel;
    bool isUploadingSuccess =
        await PostRepository.updatePost(postDataModel: postInfo);
    if (isUploadingSuccess) {
      emit(PostUploadSuccessActionState());
    } else {
      emit(PostUploadFailedActionState());
    }
  }

  FutureOr<void> postLikeButtonClickedEvent(
    PostLikeButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) async {
    final isLikedOrDisliked = await PostRepository.likeOrDislikePost(
      likes: event.likes,
      postId: event.postId,
    );
    if (!isLikedOrDisliked) {
      emit(PostLikingFailedActionState());
    }
  }

  FutureOr<void> postSaveButtonClickedEvent(
    PostSaveButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) async {
    final checkIsSaved = await PostRepository.saveOrUnsavePost(event.postId);
    if (checkIsSaved == 'saved') {
      emit(PostSavedActionState());
    } else if (checkIsSaved == 'unsaved') {
      emit(PostUnSavedActionState());
    } else {
      emit(PostSavingFailedActionState());
    }
  }

  FutureOr<void> postNavigateToLikeScreenButtonClickedEvent(
    PostNavigateToLikeScreenButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostNavigateToLikesScreenActionState());
  }

  FutureOr<void> postNavigateToCommentScreenButtonClickedEvent(
    PostNavigateToCommentScreenButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    print("PostNavigateToCommentsScreenActionState()");
    emit(PostNavigateToCommentsScreenActionState());
  }

  FutureOr<void> postAddCommentButtonClickedEvent(
    PostAddCommentButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) async {
    bool isCommentSent = await PostRepository.addComment(
      postId: event.postId,
      comment: event.comment,
    );
    if (isCommentSent) {
      print('Comment Sent');
    } else {
      print('Comment Sending failed');
    }
  }

  FutureOr<void> postShowAllPostOptionsButtonClickedEvent(
    PostShowAllPostOptionsButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostShowAllPostOptionsState());
  }

  FutureOr<void> postHideAllPostOptionsButtonClickedEvent(
    PostHideAllPostOptionsButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostHideAllPostOptionsState());
  }

  FutureOr<void> postEditPostButtonClickedEvent(
    PostEditPostButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostEditPostActionState());
  }

  FutureOr<void> postDeletePostButtonClickedEvent(
    PostDeletePostButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostDeleteActionState());
  }

  FutureOr<void> postDeleteConfirmationEvent(
    PostDeleteConfirmationEvent event,
    Emitter<PostsState> emit,
  ) async {
    bool isDeleted = await PostRepository.deletePost(postId: event.postId);
    if (isDeleted) {
      emit(PostDeleteSuccessActionState());
    }
  }

  FutureOr<void> postShowAllCommentOptionsButtonClickedEvent(
    PostShowAllCommentOptionsButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostShowAllCommentOptionsState());
  }

  FutureOr<void> postHideAllCommentOptionsButtonClickedEvent(
    PostHideAllCommentOptionsButtonClickedEvent event,
    Emitter<PostsState> emit,
  ) {
    emit(PostHideAllCommentOptionsState());
  }
}
