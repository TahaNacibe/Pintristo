import 'package:image_picker/image_picker.dart';

class ImageServices {
  //* pick image from the storage
  Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image?.path; // Return the path of the selected image
  }

Future<List<String?>> pickImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile?> images = await picker.pickMultiImage(limit: 10);
  
  // Check if images are picked, then map their paths
  List<String?> paths = images.map((img) => img?.path).toList();
  return paths; // Return the list of image paths
}

}
