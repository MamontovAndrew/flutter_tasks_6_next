import 'package:flutter/material.dart';
import '../../../models/profile_menu_model.dart';
import 'profile_menu_item.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.items,
  });

  final List<ProfileMenuModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return ProfileMenuItem(
          model: item,
          onTap: () {},
        );
      }).toList(),
    );
  }
}
