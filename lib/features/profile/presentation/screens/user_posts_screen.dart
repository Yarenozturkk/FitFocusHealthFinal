import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifesocial/components/loading.dart';
import 'package:lifesocial/constants/constants.dart';
import 'package:lifesocial/features/posts/presentation/widgets/post_card.dart';
import 'package:lifesocial/features/posts/domain/post_data_model.dart';
import 'package:lifesocial/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({super.key, required this.userId});
  final String userId;

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  bool isLoading = false;
  List<String> savedPosts = [];

  @override
  void initState() {
    super.initState();
    getSavedPosts();
  }

  void getSavedPosts() async {
    if (AuthRepository.currentUser == null) {
      // Handle the case where the current user is not available
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final docData = await FirebaseFirestore.instance
          .collection('savedPosts')
          .doc(AuthRepository.currentUser!.uid)
          .get();

      savedPosts = docData.exists ? List<String>.from(docData.data()!.keys) : [];
    } catch (e) {
      // Handle the error accordingly
      print('Error getting saved posts: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postStream = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('postedOn', descending: true)
        .snapshots();

    return isLoading
        ? const Loading()
        : StreamBuilder(
            stream: postStream,
            builder: (context, userPostSnapshots) {
              if (userPostSnapshots.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: MyColors.buttonColor1,
                  ),
                );
              }

              if (userPostSnapshots.hasError) {
                print('Error in StreamBuilder: ${userPostSnapshots.error}');
                return Center(
                  child: Text(
                    'Something went wrong!',
                    style: MyFonts.bodyFont(
                      fontColor: MyColors.secondaryColor,
                    ),
                  ),
                );
              }

              if (!userPostSnapshots.hasData || userPostSnapshots.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No Posts!',
                    style: MyFonts.bodyFont(
                      fontColor: MyColors.secondaryColor,
                    ),
                  ),
                );
              }

              final postDocuments = userPostSnapshots.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: postDocuments.length,
                itemBuilder: (context, index) {
                  bool isSaved = savedPosts.contains(postDocuments[index].id);
                  final postInfo = PostDataModel.fromJson(
                    postDocuments[index].data(),
                    postDocuments[index].id,
                  );

                  final userInfo = AuthRepository.allUsers.firstWhere(
                    (user) => user.uid == postInfo.userId,
                    orElse: () => AuthRepository.currentUser!,
                  );

                  return PostCard(
                    postInfo: postInfo,
                    userInfo: userInfo,
                    isSaved: isSaved,
                    onTapProfile: () {},
                  );
                },
              );
            },
          );
  }
}
