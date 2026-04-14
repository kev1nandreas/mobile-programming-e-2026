import 'package:flutter/material.dart';

import '../models/app_post.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class PostTab extends StatelessWidget {
  const PostTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppPost>>(
      stream: FirestoreService.instance.watchPosts(),
      builder: (context, postSnapshot) {
        final posts = postSnapshot.data ?? const <AppPost>[];

        return Stack(
          children: [
            if (postSnapshot.connectionState == ConnectionState.waiting &&
                posts.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (posts.isEmpty)
              const _EmptyState(
                title: 'No posts yet',
                message: 'Add a user first, then create posts for that user.',
              )
            else
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PostCard(post: post);
                },
              ),
            Positioned(
              right: 20,
              bottom: 24,
              child: FloatingActionButton.extended(
                onPressed: () => _PostFormSheet.open(context),
                icon: const Icon(Icons.post_add),
                label: const Text('Add post'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final AppPost post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'By ${post.userName}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _PostFormSheet.open(context, post: post);
                  } else if (value == 'delete') {
                    _confirmDelete(context, post);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.body),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppPost post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('This will remove "${post.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await FirestoreService.instance.deletePost(post.id);
    }
  }
}

class _PostFormSheet extends StatefulWidget {
  const _PostFormSheet({this.post});

  final AppPost? post;

  static Future<void> open(BuildContext context, {AppPost? post}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PostFormSheet(post: post),
    );
  }

  @override
  State<_PostFormSheet> createState() => _PostFormSheetState();
}

class _PostFormSheetState extends State<_PostFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _selectedUserId;
  bool _saving = false;
  List<AppUser> _users = const [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
    _selectedUserId = widget.post?.userId;
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.post != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Edit post' : 'Create post',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Create a user first to assign posts.'),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      items: _users
                          .map(
                            (user) => DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(user.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedUserId = value);
                      },
                      decoration: const InputDecoration(labelText: 'Author'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select a user';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(labelText: 'Body'),
                    maxLines: 5,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Body is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving || _users.isEmpty ? null : _submit,
                      child: Text(_saving ? 'Saving...' : 'Save post'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    final users = await FirestoreService.instance.fetchUsersOnce();
    if (!mounted) {
      return;
    }

    setState(() {
      _users = users;
      if (_selectedUserId == null && users.isNotEmpty) {
        _selectedUserId = users.first.id;
      }
      if (_selectedUserId != null &&
          users.every((user) => user.id != _selectedUserId)) {
        _selectedUserId = users.isNotEmpty ? users.first.id : null;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedUser = _users.firstWhere(
      (user) => user.id == _selectedUserId,
    );
    final now = DateTime.now();

    setState(() => _saving = true);
    final post =
        (widget.post ??
                AppPost(
                  id: '',
                  userId: selectedUser.id,
                  userName: selectedUser.name,
                  title: '',
                  body: '',
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              userId: selectedUser.id,
              userName: selectedUser.name,
              title: _titleController.text.trim(),
              body: _bodyController.text.trim(),
              updatedAt: now,
            );

    await FirestoreService.instance.savePost(post);

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    Navigator.pop(context);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 56, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
