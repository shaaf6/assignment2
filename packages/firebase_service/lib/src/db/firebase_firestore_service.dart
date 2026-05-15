import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_model.dart';
import '../models/reply_model.dart';
import 'firestore_service.dart';

class FirebaseFirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _topics =>
      _firestore.collection('topics');

  @override
  Stream<List<TopicModel>> getTopics() {
    return _topics
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TopicModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> createTopic(TopicModel topic) async {
    await _topics.add(topic.toMap());
  }

  @override
  Stream<List<ReplyModel>> getReplies(String topicId) {
    return _topics
        .doc(topicId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReplyModel.fromMap(doc.data(), doc.id, topicId))
            .toList());
  }

  @override
  Future<void> addReply({
    required String topicId,
    required ReplyModel reply,
  }) async {
    final batch = _firestore.batch();
    final replyRef = _topics.doc(topicId).collection('replies').doc();
    batch.set(replyRef, reply.toMap());
    batch.update(_topics.doc(topicId), {
      'replyCount': FieldValue.increment(1),
    });
    await batch.commit();
  }
}
