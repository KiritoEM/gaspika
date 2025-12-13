class SliderModel {
  String illustration;
  String title;
  String description;

  SliderModel({
    required this.title,
    required this.description,
    required this.illustration,
  });

  void setIllustration(String getIllustration) {
    illustration = getIllustration;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDescription(String getDescription) {
    description = getDescription;
  }
}
