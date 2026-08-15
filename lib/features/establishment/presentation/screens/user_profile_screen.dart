import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/utils/confirm_sign_out.dart';
import '../providers/establishment_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.fullName.trim();
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: AppColors.zuriWhite,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.zuriWhite,
        foregroundColor: AppColors.zuriNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.zuriPink.withValues(
                          alpha: 0.16,
                        ),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.zuriRed,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name == null || name.isEmpty ? 'Utilisateur' : name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.zuriNavy,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: profile?.phone ?? 'Non renseigné',
                    ),
                    const SizedBox(height: 10),
                    _ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: profile?.email?.trim().isNotEmpty == true
                          ? profile!.email!.trim()
                          : 'Non renseigné',
                    ),
                    const SizedBox(height: 10),
                    _ProfileInfoTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Statut',
                      value: profile?.phoneVerified == true
                          ? 'Téléphone vérifié'
                          : 'Téléphone non vérifié',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => confirmAndSignOut(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.zuriRed,
                  side: const BorderSide(color: AppColors.zuriRed),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Déconnexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.zuriPink.withValues(alpha: 0.12),
            child: Icon(icon, color: AppColors.zuriRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
