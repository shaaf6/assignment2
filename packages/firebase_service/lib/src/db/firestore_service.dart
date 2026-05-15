import '../models/topic_model.dart';
import '../models/reply_model.dart';

abstract class FirestoreService {
  Stream<List<TopicModel>> getTopics();
  Future<void> createTopic(TopicModel topic);
  Stream<List<ReplyModel>> getReplies(String topicId);
  Future<void> addReply({required String topicId, required ReplyModel reply});
}
