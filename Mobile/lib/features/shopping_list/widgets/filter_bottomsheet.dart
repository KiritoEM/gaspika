import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';

class FilterBottomsheet {
  static Future show(
    BuildContext context,
    PeriodFilterEnum? periodFilter,
    Function(PeriodFilterEnum? periodFilter) onSelectPeriod,
    VoidCallback onReset,
  ) async {
    const List<Map<String, dynamic>> sortFilterData = [
      {'value': PeriodFilterEnum.currentMonth, 'label': 'Ce mois'},
      {'value': PeriodFilterEnum.last5Month, 'label': '5 derniers mois'},
      {'value': PeriodFilterEnum.currentYear, 'label': 'Cette année'},
      {'value': PeriodFilterEnum.lastYear, 'label': 'Année dernière'},
    ];

    PeriodFilterEnum? selectedFilter = periodFilter;

    return await AppBottomSheet.show(
      context: context,
      builder: (context, setModalState) {
        return [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleLarge?.fontSize,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          onReset();
                          Navigator.pop(context);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          width: 1.0,
                          color: AppColors.destructive,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Effacer',
                        style: TextStyle(color: AppColors.destructive),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trier par',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 4),
                    RadioGroup(
                      groupValue: selectedFilter,
                      onChanged: (PeriodFilterEnum? value) {
                        setModalState(() {
                          selectedFilter = value;
                        });
                      },
                      child: Column(
                        children: sortFilterData.map((opt) {
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedFilter = opt['value'];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    opt['label'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Radio<PeriodFilterEnum>(
                                    value: opt['value'],
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onSelectPeriod(selectedFilter);
                      Navigator.pop(context);
                    },
                    child: Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
