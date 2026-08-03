import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'more_menu_content.dart';
import 'primary_scaffold.dart';

/// Onglet "Plus" — regroupe les destinations qui ne tiennent pas dans les
/// 4 premiers onglets de la bottom navigation. Entièrement piloté par la
/// configuration métier active.
class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PrimaryScaffold(body: MoreMenuContent());
  }
}
