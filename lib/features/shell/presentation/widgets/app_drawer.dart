import 'package:flutter/material.dart';

import 'more_menu_content.dart';

/// Menu latéral ouvert depuis l'icône hamburger du header principal — accès
/// rapide aux mêmes destinations que l'onglet "Plus", sans quitter l'écran
/// courant.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: SafeArea(child: MoreMenuContent()));
  }
}
