// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PodcastInfo _$PodcastInfoFromJson(Map<String, dynamic> json) => PodcastInfo(
      published: json['published'] as String?,
      author: json['author'] as String?,
      description: json['description'] as String?,
      heroImage: json['heroImage'] as String?,
      enclosures: (json['enclosures'] as List<dynamic>?)
          ?.map((e) => Enclosures.fromJson(e as Map<String, dynamic>))
          .toList(),
      link: json['link'] as String?,
      guid: json['guid'] as String?,
      title: json['title'] as String?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$PodcastInfoToJson(PodcastInfo instance) =>
    <String, dynamic>{
      'published': instance.published,
      'author': instance.author,
      'description': instance.description,
      'heroImage': instance.heroImage,
      'enclosures': instance.enclosures,
      'link': instance.link,
      'guid': instance.guid,
      'title': instance.title,
      'duration': instance.duration,
    };
