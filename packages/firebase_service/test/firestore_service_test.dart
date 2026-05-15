import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_service/src/db/firebase_firestore_service.dart';
import 'package:firebase_service/src/models/reply_model.dart';
import 'package:firebase_service/src/models/topic_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  WriteBatch,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late FirebaseFirestoreServiceImpl service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    service = FirebaseFirestoreServiceImpl(firestore: mockFirestore);
  });

  group('createTopic', () {
    test('calls collection add with topic data', () async {
      final mockCollection =
          MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

      when(mockFirestore.collection('topics')).thenReturn(mockCollection);
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);

      final topic = TopicModel(
        id: '',
        title: 'Test Forum Topic',
        content: 'Discussion content here',
        authorId: 'uid-001',
        authorName: 'Alice',
        authorEmail: 'alice@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      await service.createTopic(topic);

      verify(mockCollection.add(any)).called(1);
    });
  });

  group('getTopics', () {
    test('returns a stream of TopicModel list', () {
      final mockCollection =
          MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('topics')).thenReturn(mockCollection);
      when(mockCollection.orderBy('createdAt', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));
      when(mockSnapshot.docs).thenReturn([mockDoc]);
      when(mockDoc.id).thenReturn('topic-abc');
      when(mockDoc.data()).thenReturn({
        'title': 'Test Topic',
        'content': 'Some content',
        'authorId': 'uid-001',
        'authorName': 'Alice',
        'authorEmail': 'alice@example.com',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'replyCount': 2,
      });

      final stream = service.getTopics();

      expect(
        stream,
        emits(predicate<List<TopicModel>>(
          (list) => list.length == 1 && list.first.title == 'Test Topic',
        )),
      );
    });
  });

  group('addReply', () {
    test('uses a batch to add reply and increment replyCount', () async {
      final mockCollection =
          MockCollectionReference<Map<String, dynamic>>();
      final mockTopicDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockRepliesCollection =
          MockCollectionReference<Map<String, dynamic>>();
      final mockReplyDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockBatch = MockWriteBatch();

      when(mockFirestore.collection('topics')).thenReturn(mockCollection);
      when(mockCollection.doc('topic-1')).thenReturn(mockTopicDoc);
      when(mockTopicDoc.collection('replies'))
          .thenReturn(mockRepliesCollection);
      when(mockRepliesCollection.doc()).thenReturn(mockReplyDoc);
      when(mockFirestore.batch()).thenReturn(mockBatch);
      when(mockBatch.set(any, any)).thenReturn(null);
      when(mockBatch.update(any, any)).thenReturn(null);
      when(mockBatch.commit()).thenAnswer((_) async {});

      final reply = ReplyModel(
        id: '',
        topicId: 'topic-1',
        content: 'Great discussion!',
        authorId: 'uid-002',
        authorName: 'Bob',
        authorEmail: 'bob@example.com',
        createdAt: DateTime(2024, 1, 2),
      );

      await service.addReply(topicId: 'topic-1', reply: reply);

      verify(mockBatch.commit()).called(1);
    });
  });
}
