import 'package:pintresto/models/tag_model.dart';

bool isTheListsEqual(
    {required List<TagModel> firstList, required List<TagModel> secondList}) {
  if (firstList.length != secondList.length) {
    return false;
  } else if (firstList.isEmpty && secondList.isEmpty) {
    return true;
  } else {
    Set<String> firstListNames = firstList.map((tag) => tag.name).toSet();
    Set<String> secondListNames = secondList.map((tag) => tag.name).toSet();

    return firstListNames == secondListNames;
  }
}
