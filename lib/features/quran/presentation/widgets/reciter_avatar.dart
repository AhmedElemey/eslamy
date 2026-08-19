import 'package:flutter/material.dart';

import '../../service/reciter_avatar_art.dart';

/// Circular initials avatar shown for a reciter in the picker — same
/// color/initials logic used to generate the notification's [artUri], so the
/// picker and the OS media notification show a matching image.
class ReciterAvatar extends StatelessWidget {
  const ReciterAvatar({
    super.key,
    required this.reciterId,
    required this.name,
    this.size = 40,
  });

  final int reciterId;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoAsset = reciterPhotoAsset(reciterId);
    if (photoAsset != null) {
      return ClipOval(
        child: Image.asset(
          photoAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: reciterAvatarColor(reciterId),
        shape: BoxShape.circle,
      ),
      child: Text(
        reciterInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
