import 'package:lifesocial/constants/constants.dart';
import 'package:lifesocial/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class AddCommentField extends StatelessWidget {
  AddCommentField({
    super.key,
    required this.postsBloc,
    required this.postId,
  });

  final PostsBloc postsBloc;
  final String postId;
  final TextEditingController _commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            height: 50,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MyColors.tercharyColor,
                width: 0.5,
              ),
            ),
            child: TextField(
              key: const ValueKey('commentField'),
              style: MyFonts.bodyFont(
                fontColor: MyColors.tercharyColor,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: 'Add a comment',
                hintStyle: MyFonts.bodyFont(
                  fontColor: MyColors.tercharyColor,
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_commentTextController.text.trim().isEmpty) {
                      return;
                    }
                    postsBloc.add(PostAddCommentButtonClickedEvent(
                        postId: postId, comment: _commentTextController.text));
                    FocusManager.instance.primaryFocus!.unfocus();
                    _commentTextController.clear();
                  },
                  icon: Icon(
                    IconlyLight.send,
                    color: MyColors.buttonColor1,
                  ),
                ),
              ),
              controller: _commentTextController,
              onSubmitted: (comment) {
                if (comment.trim().isEmpty) {
                  return;
                }
                postsBloc.add(PostAddCommentButtonClickedEvent(
                  postId: postId,
                  comment: _commentTextController.text,
                ));
                _commentTextController.clear();
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus!.unfocus(),
            ),
          ),
        ),
      ],
    );
  }
}
