import 'package:flutter/material.dart';
import '../../../models/profile_menu_model.dart';
import '../../../res/dimentions.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.model,
    required this.onTap,
  });

  final ProfileMenuModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.profileMenuHeight,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              model.iconPath,
              height: AppDimens.profileMenuImageSize,
              width: AppDimens.profileMenuImageSize,
            ),
            const SizedBox(width: 20),
            Text(
              model.label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
