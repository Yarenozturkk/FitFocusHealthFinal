import 'package:lifesocial/components/custom_elevated_button.dart';
import 'package:lifesocial/constants/constants.dart';
import 'package:lifesocial/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:lifesocial/features/posts/domain/post_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../components/network_image_widget.dart';
import '../../../../components/show_snackbar.dart';
import '../../../../service_locator/service_locator.dart';
import 'add_post_screen.dart';

class UploadPostScreen extends StatefulWidget {
  static const routeName = '/upload-post-screen';
  UploadPostScreen({super.key});

  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final TextEditingController _captionTextController = TextEditingController();
  final TextEditingController _caloriesTextController = TextEditingController();
  final postsBloc = ServiceLocator.instance.get<PostsBloc>();

  final List<Map<String, dynamic>> _foods = [
    {'name': 'Apple', 'calories': 52},
    {'name': 'Watermelon', 'calories': 30},
    {'name': 'Banana', 'calories': 89},
    {'name': 'Orange', 'calories': 47},
    {'name': 'Grapes', 'calories': 69},
    {'name': 'Strawberry', 'calories': 32},
    {'name': 'Tomato', 'calories': 18},
    {'name': 'Cucumber', 'calories': 16},
    {'name': 'Carrot', 'calories': 41},
    {'name': 'Broccoli', 'calories': 34},
  ];

  String? _selectedFood;
  int _selectedCalories = 0;

  @override
  Widget build(BuildContext context) {
    final routeData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final isEditing = routeData['isEditing'];
    dynamic image;
    PostDataModel? postDataModel;
    if (!isEditing) {
      image = routeData['image'];
    }
    if (isEditing) {
      postDataModel = routeData['postDataModel'];
      _captionTextController.text = postDataModel!.caption;
      _caloriesTextController.text = postDataModel.calories.toString();
    }

    void _showFoodDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Food'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _foods.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_foods[index]['name']),
                    onTap: () {
                      setState(() {
                        _selectedFood = _foods[index]['name'];
                        _selectedCalories = _foods[index]['calories'];
                        _caloriesTextController.text =
                            _selectedCalories.toString();
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return BlocListener<PostsBloc, PostsState>(
      bloc: postsBloc,
      listenWhen: (previous, current) => current is PostsActionState,
      listener: (context, state) {
        if (state is PostChooseUploadOptionActionState) {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            backgroundColor: MyColors.primaryColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            builder: (context) => SizedBox(
              height: 300,
              width: double.infinity,
              child: AddPostScreen(isChangingImage: state.isChangingImage),
            ),
          );
        } else if (state is PostUploadSuccessActionState) {
          Navigator.pop(context);
          ShowSnackBar(
            context: context,
            label: isEditing
                ? 'Post successfully updated.'
                : 'Post successfully uploaded.',
            color: MyColors.buttonColor1,
          ).show();
        }
      },
      child: Scaffold(
        backgroundColor: MyColors.primaryColor,
        appBar: AppBar(
          backgroundColor: MyColors.primaryColor,
          iconTheme: IconThemeData(color: MyColors.secondaryColor),
          actions: [
            BlocBuilder<PostsBloc, PostsState>(
              bloc: postsBloc,
              buildWhen: (previous, current) => current is PostsActionState,
              builder: (context, state) {
                return state is PostUploadingActionState
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: MyColors.buttonColor1,
                        ),
                      )
                    : CustomElevatedButton(
                        onPressed: () {
                          if (isEditing) {
                            postsBloc.add(PostUpdateButtonClickedEvent(
                              postDataModel: postDataModel!.copyWith(
                                caption: _captionTextController.text,
                                calories: int.parse(_caloriesTextController.text),
                                postedOn: DateTime.now(),
                              ),
                            ));
                          } else {
                            postsBloc.add(
                              PostUploadButtonClickedEvent(
                                caption: _captionTextController.text,
                                image: image,
                                calories: int.parse(_caloriesTextController.text),
                              ),
                            );
                          }
                        },
                        title: isEditing ? 'Save' : 'Post',
                        width: 100,
                        height: 40,
                        color: MyColors.buttonColor1,
                      );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                maxLines: 3,
                style: MyFonts.bodyFont(
                  fontColor: MyColors.secondaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a caption',
                  hintStyle: MyFonts.bodyFont(
                    fontColor: MyColors.secondaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                controller: _captionTextController,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus!.unfocus(),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _showFoodDialog,
                icon: Icon(IconlyLight.plus, color: MyColors.secondaryColor),
                label: Text(
                  'Select Food',
                  style: MyFonts.bodyFont(
                    fontColor: MyColors.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: isEditing
                        ? NetworkImageWidget(
                            height: 300,
                            width: double.infinity,
                            imageUrl: postDataModel!.postUrl,
                          )
                        : Image.file(
                            image,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (_selectedFood != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.black54,
                        child: Text(
                          '$_selectedCalories Cal',
                          style: MyFonts.bodyFont(
                            fontColor: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (!isEditing)
                TextButton.icon(
                  onPressed: () {
                    postsBloc.add(PostChooseImageButtonClickedEvent(
                        isChagingImage: true));
                  },
                  icon: Icon(
                    IconlyLight.camera,
                    color: MyColors.secondaryColor,
                  ),
                  label: Text(
                    'Change Image',
                    style: MyFonts.bodyFont(
                      fontColor: MyColors.secondaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
