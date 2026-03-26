import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:gaspika_mobile/features/notification/widgets/notification_card.dart';
import 'package:gaspika_mobile/features/notification/widgets/notifications_list_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notificationVm = Provider.of<NotificationViewModel>(
        context,
        listen: false,
      );

      await notificationVm.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationVm = Provider.of<NotificationViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          onPressed: () => context.pop(true),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notificationVm.refreshAll(),
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: _buildBody(notificationVm),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationViewModel notificationVm) {
    bool isListEmpty = notificationVm.notifications.isEmpty;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          if (notificationVm.isLoadingNotifications)
            Padding(
              padding: EdgeInsets.fromLTRB(23, 12, 23, 23),
              child: NotificationsListSkeleton(),
            )
          else if (!isListEmpty)
            _buildNotificationsList(notificationVm),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationViewModel notificationVm) {
    return Column(
      children: notificationVm.notifications
          .map(
            (notif) => NotificationCard(
              image: notif.image,
              details: notif.body,
              type: notif.type,
              route: notif.route ?? NavigationConstant.DEFAULT_ROUTE,
              isRead: notif.isRead,
              createdAt: notif.createdAt,
            ),
          )
          .toList(),
    );
  }
}
