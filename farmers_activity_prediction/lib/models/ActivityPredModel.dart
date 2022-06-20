class ActivityPredModel {
  String id;
  String image;
  String estimatedImage;
  String predictedPose;
  DateTime createdAt;
  DateTime updatedAt;

  ActivityPredModel({
    this.id,
    this.image,
    this.estimatedImage,
    this.predictedPose,
    this.createdAt,
    this.updatedAt,
  });
  
  factory ActivityPredModel.fromJson(Map<String, dynamic> json) => ActivityPredModel(
    id: json["id"],
    image: json["image"],
    estimatedImage: json["estimated_image"],
    predictedPose: json["predicted_pose"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );
}
