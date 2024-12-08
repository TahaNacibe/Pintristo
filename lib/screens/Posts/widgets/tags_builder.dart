import 'package:flutter/material.dart';
import 'package:pintresto/models/tag_model.dart';
import 'package:pintresto/screens/Posts/widgets/tag_widget.dart';

class TagsBuilder extends StatefulWidget {
  final List<TagModel> tags;
  final List<TagModel> selectedTags;
  final void Function(TagModel tag) onClick;
  const TagsBuilder({required this.tags,required this.selectedTags,required this.onClick,super.key});

  @override
  State<TagsBuilder> createState() => _TagsBuilderState();
}

class _TagsBuilderState extends State<TagsBuilder> {
  //*
   // is item selected
  bool isTagSelected({required TagModel tag}) {
    List<String> selectedTagsNames =
        widget.selectedTags.map((tag) => tag.name).toList();
    return selectedTagsNames.contains(tag.name);
  }
  @override
  Widget build(BuildContext context) {
    return itemsWidget(tags: widget.tags);
  }

   Widget itemsWidget({required List<TagModel> tags}) {
    return Expanded(
      child: GridView.builder(
          itemCount: tags.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 3,
              childAspectRatio: 2.5),
          itemBuilder: (context, index) {
            //* var
            TagModel tagItem = tags[index];
            bool showItem = isTagSelected(tag: tagItem);
            //* Ui tree
            if (showItem) {
              return const SizedBox.shrink();
            } else {
              return tagWidget(
                  title: tagItem.name,
                  isSelected: false,
                  onClick: () =>
                      widget.onClick(tagItem));
            }
          }),
    );
  }
}
