import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_post.dart';
import '../models/app_user.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  Stream<List<AppUser>> watchUsers() {
    return _users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AppUser.fromDoc).toList());
  }

  Stream<List<AppPost>> watchPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AppPost.fromDoc).toList());
  }

  Future<List<AppUser>> fetchUsersOnce() async {
    final snapshot = await _users.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(AppUser.fromDoc).toList();
  }

  Future<void> saveUser(AppUser user) async {
    final now = DateTime.now();
    final isNew = user.id.isEmpty;
    final docRef = isNew ? _users.doc() : _users.doc(user.id);
    final existing = isNew ? null : await docRef.get();
    final createdAt = existing?.data()?['createdAt'] is Timestamp
        ? (existing!.data()!['createdAt'] as Timestamp).toDate()
        : user.createdAt;

    final payload = user.copyWith(
      id: docRef.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    await docRef.set(payload.toMap(), SetOptions(merge: true));

    if (!isNew &&
        existing?.exists == true &&
        existing?.data()?['name'] != payload.name) {
      await _syncPostsForUserNameChange(docRef.id, payload.name);
    }
  }

  Future<void> deleteUser(String userId) async {
    final batch = _firestore.batch();
    final userPosts = await _posts.where('userId', isEqualTo: userId).get();
    for (final post in userPosts.docs) {
      batch.delete(post.reference);
    }
    batch.delete(_users.doc(userId));
    await batch.commit();
  }

  Future<void> savePost(AppPost post) async {
    final now = DateTime.now();
    final isNew = post.id.isEmpty;
    final docRef = isNew ? _posts.doc() : _posts.doc(post.id);
    final existing = isNew ? null : await docRef.get();
    final createdAt = existing?.data()?['createdAt'] is Timestamp
        ? (existing!.data()!['createdAt'] as Timestamp).toDate()
        : post.createdAt;

    final payload = post.copyWith(
      id: docRef.id,
      createdAt: createdAt,
      updatedAt: now,
    );

    await docRef.set(payload.toMap(), SetOptions(merge: true));
  }

  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();
  }

  Future<void> _syncPostsForUserNameChange(
    String userId,
    String userName,
  ) async {
    final snapshot = await _posts.where('userId', isEqualTo: userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'userName': userName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
    await batch.commit();
  }
}
