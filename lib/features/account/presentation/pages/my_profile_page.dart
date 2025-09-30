import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import 'about_me_page.dart';
import 'work_experience_page.dart';
import 'education_page.dart';
import 'skills_page.dart';
import 'years_of_experience_page.dart';
// import 'package:image_picker/image_picker.dart';
import '../widgets/image_preview_page.dart';
// import 'package:image_cropper/image_cropper.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late final AccountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AccountBloc>();
    _bloc.add(AccountLoadProfile());
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
        appBar: AppBar(title: const Text('My Profile')),
        body: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AccountProfileLoaded) {
              return _ProfileView(profile: state.profile);
            }
            if (state is AccountError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final UserProfile profile;
  const _ProfileView({required this.profile});

  Future<String?> _pickImagePath() async {
    try {
      // TODO: Image picker functionality temporarily disabled
      // final picker = ImagePicker();
      // final XFile? file = await picker.pickImage(
      //     source: ImageSource.gallery, maxWidth: 2048, imageQuality: 92);
      // if (file == null) return null;
      // final cropped = await ImageCropper().cropImage(
      //   sourcePath: file.path,
      //   aspectRatioPresets: const [
      //     CropAspectRatioPreset.square,
      //     CropAspectRatioPreset.ratio4x3,
      //     CropAspectRatioPreset.original,
      //   ],
      //   uiSettings: [
      //     AndroidUiSettings(
      //       toolbarTitle: 'Crop Photo',
      //       toolbarColor: Colors.black,
      //       toolbarWidgetColor: Colors.white,
      //       hideBottomControls: false,
      //       lockAspectRatio: false,
      //     ),
      //     IOSUiSettings(title: 'Crop Photo'),
      //   ],
      // );
      // return cropped?.path ?? file.path;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (profile.profileImage != null &&
                            profile.profileImage!.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ImagePreviewPage(
                                  imageUrl: profile.profileImage!,
                                  heroTag: 'profile_photo')));
                        }
                      },
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.softPink,
                        child: profile.profileImage != null &&
                                profile.profileImage!.isNotEmpty
                            ? Hero(
                                tag: 'profile_photo',
                                child: ClipOval(
                                  child: Image.network(
                                    profile.profileImage!,
                                    width: 64,
                                    height: 64,
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
                          // pick & upload photo
                          final picker = await _pickImagePath();
                          if (picker != null && context.mounted) {
                            context
                                .read<AccountBloc>()
                                .add(AccountUploadProfileImage(picker));
                          }
                        },
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.orange,
                          child: Icon(Icons.camera_alt,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName
                              : 'Unnamed',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (profile.email != null) Text(profile.email!),
                      if (profile.phone != null) Text(profile.phone!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('About'),
            subtitle: Text(profile.bio ?? '—'),
            trailing: const Icon(Icons.edit),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccountBloc>(),
                  child: AboutMePage(initial: profile),
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Job Title'),
            subtitle: Text(profile.jobTitle ?? '—'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Location'),
            subtitle: Text(profile.location ?? '—'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Years of experience'),
            subtitle: Text(profile.yearsOfExperience?.toString() ?? '—'),
            trailing: const Icon(Icons.edit),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccountBloc>(),
                  child:
                      YearsOfExperiencePage(initial: profile.yearsOfExperience),
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Work Experience'),
            subtitle: Text('${profile.workExperience.length} items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccountBloc>(),
                  child: WorkExperiencePage(items: profile.workExperience),
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Education/Certification'),
            subtitle: Text('${profile.education.length} items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccountBloc>(),
                  child: EducationPage(items: profile.education),
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Skills'),
            subtitle: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.skills.isEmpty
                  ? [const Text('—')]
                  : profile.skills.map((s) => Chip(label: Text(s))).toList(),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AccountBloc>(),
                  child: SkillsPage(initial: profile.skills),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
