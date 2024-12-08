String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text; // If text is empty, return it as is
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
