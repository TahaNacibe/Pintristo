import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';

class CreatedPinsPage extends StatefulWidget {
  final Map<String, dynamic> posts;
  const CreatedPinsPage({required this.posts, super.key});

  @override
  State<CreatedPinsPage> createState() => _CreatedPinsPageState();
}

class _CreatedPinsPageState extends State<CreatedPinsPage> {
  @override
  Widget build(BuildContext context) {
    List<PostModel> created = widget.posts["created"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: MasonryGridView.builder(
          itemCount: created.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PinScreen(
                              post: created[index],
                              deleteAction: (postId) {
                                setState(() {
                                  created.removeWhere(
                                      (elem) => elem.postId == postId);
                                });
                              },
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                        image: NetworkImage(created[index].imageUrl),
                        fit: BoxFit.cover)),
              ),
            );
          }),
    );
  }
}
