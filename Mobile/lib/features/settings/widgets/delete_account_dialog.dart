import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/shared/password_input_field.dart';
import 'package:provider/provider.dart';

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onDelete;

  const DeleteAccountDialog({super.key, required this.onDelete});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  late SettingsViewmodel settingsVm;

  @override
  void initState() {
    super.initState();

    settingsVm = Provider.of<SettingsViewmodel>(context, listen: false);
    settingsVm.deletePasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      title: const Text(
        'Supprimer mon compte',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              'Cette action est irréversible. Vos listes de courses, vos aliments et vos notifications seront définitivement supprimés.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),

            Text(
              'Confirmez avec votre mot de passe pour continuer.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),

            PasswordInputField(
              label: 'Mot de passe',
              controller: settingsVm.deletePasswordController,
            ),
          ],
        ),
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
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: settingsVm.deletePasswordController,
                builder: (context, value, _) {
                  return ElevatedButton(
                    onPressed: value.text.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);

                            widget.onDelete();
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.destructive,
                    ),
                    child: const Text('Supprimer'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
