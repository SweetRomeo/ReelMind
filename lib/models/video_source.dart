enum VideoSourceType { asset, network }

class VideoSource {
  final VideoSourceType type;
  final String location;

  const VideoSource.asset(this.location)
      : type = VideoSourceType.asset;

  const VideoSource.network(this.location)
      : type = VideoSourceType.network;

  @override
  bool operator ==(Object other) =>
      other is VideoSource &&
      other.type == type &&
      other.location == location;

  @override
  int get hashCode => Object.hash(type, location);
}