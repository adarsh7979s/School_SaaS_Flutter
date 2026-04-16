import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 28,
  });

  final String imageUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          width: radius * 2,
          height: radius * 2,
          color: const Color(0xFFD9E7F8),
          alignment: Alignment.center,
          child: SizedBox(
            width: radius,
            height: radius,
            child: const CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
        errorWidget: (context, _, __) => Container(
          width: radius * 2,
          height: radius * 2,
          color: const Color(0xFFEFE3D8),
          alignment: Alignment.center,
          child: Text(
            _initials(name),
            style: TextStyle(
              fontSize: radius * 0.6,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B3720),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
