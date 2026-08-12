import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutConfirmationDialog({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      title: const Text(
        'Se déconnecter',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Voulez-vous vraiment vous déconnecter de votre compte ?',
        style: TextStyle(color: AppColors.mutedForeground),
      ),

      actions: [
        Row(
          spacing: 8,

          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
            ),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  onLogout();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.destructive,  
                ),
                child: const Text('Déconnexion'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
