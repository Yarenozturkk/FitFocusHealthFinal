import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../profile/presentation/screens/current_user_profile.dart';
import '../../../profile/presentation/screens/other_users_profile.dart';
import '/components/custom_app_top_bar.dart';
import '/components/loading.dart';
import '../../../auth/data/auth_repository.dart';
import '../widgets/post_card.dart';
import '/constants/constants.dart';
import '../../domain/post_data_model.dart';

class PostsFeed extends StatefulWidget {
  const PostsFeed({super.key});

  @override
  State<PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<PostsFeed> {
  List<String> savedPosts = [];
  bool isLoading = false;

  @override
  void initState() {
    getSavedPosts();
    super.initState();
  }

  void getSavedPosts() async {
    setState(() {
      isLoading = true;
    });
    final docData = await FirebaseFirestore.instance
        .collection('savedPosts')
        .doc(AuthRepository.currentUser!.uid)
        .get();
    savedPosts = docData.exists ? docData.data()!.keys.toList() : List.empty();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postedOn', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: customAppBar(title: 'FitFocusHealth'),
      body: isLoading
          ? const Loading()
          : StreamBuilder(
              stream: postStream,
              builder: (context, postSnapshots) {
                if (postSnapshots.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }
                final postDocuments = postSnapshots.data!.docs;
                if (postDocuments.isEmpty) {
                  return Center(
                    child: Text(
                      'No Posts!',
                      style: MyFonts.bodyFont(
                        fontColor: MyColors.secondaryColor,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: postDocuments.length,
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 80, left: 20, right: 20),
                    itemBuilder: (context, index) {
                      bool isSaved =
                          savedPosts.contains(postDocuments[index].id);
                      final postInfo = PostDataModel.fromJson(
                        postDocuments[index].data(),
                        postDocuments[index].id,
                      );
                      final userInfo = AuthRepository.allUsers
                          .firstWhere((user) => user.uid == postInfo.userId);
                      return PostCard(
                        key: ValueKey(postInfo.postId),
                        postInfo: postInfo,
                        userInfo: userInfo,
                        isSaved: isSaved,
                        onTapProfile: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AuthRepository.currentUser!.uid ==
                                          postInfo.userId
                                      ? const CurrentUserProfile(
                                          showBackButton: true,
                                        )
                                      : OtherUsersProfile(
                                          userId: postInfo.userId,
                                          showBackButton: true,
                                        ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
