import 'package:flutter/material.dart';

class MenuItemModel {
  final IconData icon;
  final String title;
  final bool isVerifiedOption;

  const MenuItemModel({
    required this.icon,
    required this.title,
    this.isVerifiedOption = false,
  });
}

// Data is now defined in the Model layer
const menuItems = [
  MenuItemModel(icon: Icons.check_circle_outline, title: 'Get Verified', isVerifiedOption: true),
  MenuItemModel(icon: Icons.share, title: 'Share App'),
  MenuItemModel(icon: Icons.help_outline, title: 'Help & Support'),
  MenuItemModel(icon: Icons.settings, title: 'Settings'),
  MenuItemModel(icon: Icons.brightness_6, title: 'Toggle Theme'),
  MenuItemModel(icon: Icons.local_activity_rounded, title: 'Activity'),
  MenuItemModel(icon: Icons.logout, title: 'Logout'),
];
