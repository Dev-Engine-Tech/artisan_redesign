import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme.dart';
import '../../../../core/di.dart';
import '../../../../core/components/components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import 'my_profile_page.dart';
import 'my_earnings_page.dart';
import 'add_bank_page.dart';
import 'subscription_page.dart';
import 'contact_us_page.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
import '../widgets/image_preview_page.dart';
import 'raise_ticket_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/push_registration_service.dart';
import '../../../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../../../core/utils/responsive.dart';

class SupportAccountPage extends StatefulWidget {
  const SupportAccountPage({super.key});

  @override
  State<SupportAccountPage> createState() => _SupportAccountPageState();
}

class _SupportAccountPageState extends State<SupportAccountPage> {
  late final AccountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AccountBloc>();
    // ✅ PERFORMANCE FIX: Check state before loading
    final currentState = _bloc.state;
    if (currentState is! AccountProfileLoaded) {
      _bloc.add(AccountLoadProfile());
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          backgroundColor: AppColors.brownHeader,
        ),
        body: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AccountError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            UserProfile? profile;
            if (state is AccountProfileLoaded) profile = state.profile;

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: context.maxContentWidth,
                ),
                child: ListView(
                  padding: context.responsivePadding,
                  children: [
                    _HeaderCard(profile: profile),
                    AppSpacing.spaceLG,
                    const _SectionTitle('Account'),
                    _MenuTile(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const MyProfilePage()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'My Earnings',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const MyEarningsPage()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.account_balance_outlined,
                      title: 'Add Bank',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddBankPage()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Subscription',
                      onTap: () => SubscriptionModal.show(context),
                    ),
                    AppSpacing.spaceMD,
                    const _SectionTitle('Help'),
                    _MenuTile(
                      icon: Icons.support_agent,
                      title: 'Contact Us',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ContactUsPage()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Diagnostics',
                      onTap: () => _showPushDiagnostics(context),
                    ),
                    _MenuTile(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Raise a ticket',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RaiseTicketPage()),
                        );
                      },
                    ),
                    _MenuTile(
                      icon: Icons.update_rounded,
                      title: 'Check For Updates',
                      onTap: () => _checkForUpdates(context),
                    ),
                    AppSpacing.spaceMD,
                    const _SectionTitle('Security'),
                    _MenuTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    _MenuTile(
                      icon: Icons.logout,
                      title: 'Log Out',
                      onTap: () =>
                          context.read<AuthBloc>().add(AuthSignedOut()),
                    ),
                    _MenuTile(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      isDestructive: true,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPushDiagnostics(BuildContext context) async {
    final svc = getIt<PushRegistrationService>();
    final remote = getIt<NotificationRemoteDataSource>();
    Map<String, String> diag = {};
    try {
      diag = await svc.getDiagnostics();
    } catch (_) {}

    // Build friendly labels
    String fcmToken = diag['fcmToken'] ?? '—';
    String fcmTokenShort = fcmToken.isEmpty
        ? '—'
        : '${fcmToken.substring(0, fcmToken.length > 20 ? 20 : fcmToken.length)}…';
    final deviceId = diag['deviceId'] ?? '—';
    final deviceType = diag['deviceType'] ?? '—';
    final lastStatus = diag['lastStatus'] ?? '—';
    final lastStatusAt = diag['lastStatusAt'] ?? '—';
    final lastError = diag['lastError'];

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Push Diagnostics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv('Device type', deviceType),
            _kv('Device ID', deviceId),
            Row(
              children: [
                Expanded(child: _kv('FCM token', fcmTokenShort)),
                IconButton(
                  tooltip: 'Copy full token',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: fcmToken == '—'
                      ? null
                      : () async {
                          await Clipboard.setData(
                              ClipboardData(text: fcmToken));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('FCM token copied')),
                            );
                          }
                        },
                ),
              ],
            ),
            _kv('Last status', lastStatus),
            _kv('Last status at', lastStatusAt),
            if (lastError != null && lastError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Last error: $lastError',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Register Again',
            onPressed: () async {
              try {
                await getIt<PushRegistrationService>().registerIfPossible();
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  _showPushDiagnostics(context); // refresh
                }
              } catch (_) {}
            },
          ),
          TextAppButton(
            text: 'Send Test Push',
            onPressed: () async {
              try {
                await remote.sendTestPush(
                    title: 'Test', body: 'Hello from app');
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test push requested')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to request test push: $e')),
                  );
                }
              }
            },
          ),
          TextAppButton(
            text: 'Close',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: AppSpacing.verticalXS,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text(k,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            AppSpacing.spaceSM,
            Expanded(child: Text(v)),
          ],
        ),
      );

  Future<void> _checkForUpdates(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final latest =
          const String.fromEnvironment('LATEST_VERSION', defaultValue: '');
      final storeUrl = const String.fromEnvironment('APP_UPDATE_URL',
          defaultValue: 'https://artisansbridge.com');
      if (latest.isNotEmpty && latest != current) {
        final uri = Uri.parse(storeUrl);
        // TODO: URL launcher functionality temporarily disabled
        // if (await canLaunchUrl(uri)) {
        //   await launchUrl(uri, mode: LaunchMode.externalApplication);
        // }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Update available: $latest (current $current)')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are up to date ($current)')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to check updates right now')),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldCtr = TextEditingController();
    final newCtr = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: oldCtr,
              obscureText: true,
              label: 'Old Password',
              showLabel: true,
            ),
            AppSpacing.spaceSM,
            CustomTextField(
              controller: newCtr,
              obscureText: true,
              label: 'New Password',
              showLabel: true,
            ),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          PrimaryButton(
            text: 'Update',
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AccountBloc>().add(AccountChangePassword(
                  oldPassword: oldCtr.text, newPassword: newCtr.text));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final otpCtr = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action cannot be undone'),
            AppSpacing.spaceSM,
            CustomTextField(
              controller: otpCtr,
              label: 'OTP (optional)',
              showLabel: true,
            ),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          PrimaryButton(
            text: 'Delete',
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AccountBloc>().add(AccountDeleteAccount(
                  otp: otpCtr.text.isEmpty ? null : otpCtr.text));
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final UserProfile? profile;
  const _HeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () {
                    final url = profile?.profileImage;
                    if (url != null && url.isNotEmpty) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ImagePreviewPage(
                              imageUrl: url, heroTag: 'support_profile')));
                    }
                  },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.softPink,
                    child: profile?.profileImage != null &&
                            profile!.profileImage!.isNotEmpty
                        ? Hero(
                            tag: 'support_profile',
                            child: ClipOval(
                              child: Image.network(
                                profile!.profileImage!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline,
                                    color: AppColors.orange),
                              ),
                            ),
                          )
                        : const Icon(Icons.person_outline,
                            color: AppColors.orange),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // TODO: Image picker functionality temporarily disabled
                      // final picker = ImagePicker();
                      // final XFile? file = await picker.pickImage(
                      //     source: ImageSource.gallery, maxWidth: 2048, imageQuality: 92);
                      // String? path = file?.path;
                      // if (path != null) {
                      //   final cropped = await ImageCropper().cropImage(
                      //     sourcePath: path,
                      //     aspectRatioPresets: const [
                      //       CropAspectRatioPreset.square,
                      //       CropAspectRatioPreset.ratio4x3,
                      //       CropAspectRatioPreset.original,
                      //     ],
                      //     uiSettings: [
                      //       AndroidUiSettings(
                      //         toolbarTitle: 'Crop Photo',
                      //         toolbarColor: Colors.black,
                      //         toolbarWidgetColor: Colors.white,
                      //         hideBottomControls: false,
                      //         lockAspectRatio: false,
                      //       ),
                      //       IOSUiSettings(title: 'Crop Photo'),
                      //     ],
                      //   );
                      //   path = cropped?.path ?? path;
                      // }
                      // if (path != null && context.mounted) {
                      //   context
                      //       .read<AccountBloc>()
                      //       .add(AccountUploadProfileImage(path));
                      // }
                    },
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.orange,
                      child:
                          Icon(Icons.camera_alt, size: 12, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            AppSpacing.spaceMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName.isNotEmpty == true
                        ? profile!.fullName
                        : 'Your Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (profile?.phone != null && profile!.phone!.isNotEmpty)
                    Text(profile!.phone!,
                        style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.brownHeader)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;
  const _MenuTile(
      {required this.icon,
      required this.title,
      this.onTap,
      this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(10)),
          padding: AppSpacing.paddingSM,
          child: Icon(icon,
              color: isDestructive ? AppColors.danger : AppColors.orange),
        ),
        title: Text(title,
            style: TextStyle(color: isDestructive ? AppColors.danger : null)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
