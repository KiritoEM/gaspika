import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class AvalaibleProductCard extends StatelessWidget {
  int productCount;

  AvalaibleProductCard({super.key, this.productCount = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            // Badge icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                'assets/icons/pajamas_planning.svg',
                width: 33,
                height: 33,
              ),
            ),

            SizedBox(width: 16),

            // Text info
            Expanded(
              child: Text(
                '${productCount > 0 ? productCount : 'Aucun'} aliment${productCount > 1 ? 's' : ''} disponible${productCount > 1 ? 's' : ''} dans ton planning',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(width: 6),

            // IconButton(
            //   onPressed: () {},
            //   icon: Icon(
            //     Icons.arrow_forward_ios,
            //     color: Colors.white,
            //     size: 24,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
