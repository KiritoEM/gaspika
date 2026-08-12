import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:gaspika_mobile/features/notification/widgets/notification_card.dart';
import 'package:gaspika_mobile/features/notification/widgets/notification_empty_state.dart';
import 'package:gaspika_mobile/features/notification/widgets/notifications_list_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationsScreen> {
  late NotificationViewModel _notificationVm;

  Future handleDeleteList(
    String notificationId,
    NotificationViewModel notificationVm,
  ) async {
    await notificationVm.deleteNotification(notificationId);

    if (!mounted) return;

    if (!notificationVm.hasDeleteError &&
        !notificationVm.isDeletingNotification) {
      Toastify.show(
        context,
        message: 'Notification supprimée avec succès.',
        type: ToastType.success,
      );
    } else {
      Toastify.show(
        context,
        message: notificationVm.deleteErrorMessage,
        type: ToastType.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _notificationVm = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );

    Future.microtask(() => _notificationVm.fetchNotifications());
  }

  @override
  void dispose() {
    // mark all notifications as read when leaving the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationVm.markAllAsRead();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NotificationViewModel notificationConsumerVm =
        Provider.of<NotificationViewModel>(context);

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
          onRefresh: () => notificationConsumerVm.refreshAll(),
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: _buildBody(notificationConsumerVm),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationViewModel notificationVm) {
    bool isListEmpty = notificationVm.notifications.isEmpty;

    if (notificationVm.isLoadingNotifications) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(23, 12, 23, 23),
          child: NotificationsListSkeleton(),
        ),
      );
    }

    if (isListEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: NotificationEmptyState(),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: _buildNotificationsList(notificationVm),
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
              isRead: notif.isRead,
              createdAt: notif.createdAt,
              onTap: () async {
                await notificationVm.markNotificationAsRead(notif.id);
                await context.push(
                  notif.route ?? NavigationConstant.DEFAULT_ROUTE,
                );
              },
              onDelete: () async => handleDeleteList(notif.id, notificationVm),
            ),
          )
          .toList(),
    );
  }
}
