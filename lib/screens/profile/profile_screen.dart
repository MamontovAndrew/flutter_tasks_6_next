import 'package:flutter/material.dart';
import '../../models/profile_menu_model.dart';
import '../../res/dimentions.dart';
import '../../res/assets.dart';
import 'components/profile_additional_menu.dart';
import 'components/profile_menu.dart';
import 'components/profile_overview.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<ProfileMenuModel> menuItems = const [
    ProfileMenuModel(
      iconPath: Assets.ordersIcon,
      label: 'Мои заказы',
    ),
    ProfileMenuModel(
      iconPath: Assets.cardsIcon,
      label: 'Медицинские карты',
    ),
    ProfileMenuModel(
      iconPath: Assets.addressIcon,
      label: 'Мои адреса',
    ),
    ProfileMenuModel(
      iconPath: Assets.settingsIcon,
      label: 'Настройки',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileOverview(),
          const SizedBox(height: AppDimens.spacingLarge),
          ProfileMenu(items: menuItems),
          const SizedBox(height: AppDimens.spacingLarge),
          const Center(child: ProfileAdditionalMenu()),
        ],
      ),
    );
  }
}
