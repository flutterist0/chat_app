import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendshipService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FriendshipService(this._firestore, this._auth);

  Future<void> sendFollowRequest(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();

    final outgoingRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('requests')
        .doc(targetUserId);

    batch.set(outgoingRef, {
      'uid': targetUserId,
      'type': 'outgoing',
      'timestamp': timestamp,
      'status': 'pending',
    });

    final incomingRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('requests')
        .doc(currentUser.uid);

    batch.set(incomingRef, {
      'uid': currentUser.uid,
      'type': 'incoming',
      'timestamp': timestamp,
      'status': 'pending',
    });
    
    final notificationRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .doc();
    
    batch.set(notificationRef, {
      'type': 'follow_request',
      'senderId': currentUser.uid,
      'senderName': currentUser.displayName ?? 'Unknown',
      'senderPhoto': currentUser.photoURL,
      'title': 'Yeni Takip İstəyi',
      'body': '${currentUser.displayName} sizi takip etmək istəyir.',
      'timestamp': timestamp,
      'isRead': false,
      'status': 'pending', 
      'requestId': currentUser.uid,
    });

    await batch.commit();
  }

  Future<void> acceptFollowRequest(String senderId, [String? notificationId]) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.runTransaction((transaction) async {
      final myUserRef = _firestore.collection('users').doc(currentUser.uid);
      final myFollowerRef = myUserRef.collection('followers').doc(senderId);
      
      final followerDoc = await transaction.get(myFollowerRef);
      if (followerDoc.exists) {
        return;
      }

      final timestamp = FieldValue.serverTimestamp();

      transaction.set(myFollowerRef, {
        'uid': senderId,
        'timestamp': timestamp,
      });

      final senderUserRef = _firestore.collection('users').doc(senderId);
      final senderFollowingRef = senderUserRef.collection('following').doc(currentUser.uid);
      
      transaction.set(senderFollowingRef, {
        'uid': currentUser.uid,
        'timestamp': timestamp,
      });

      final myRequestRef = myUserRef.collection('requests').doc(senderId);
      transaction.delete(myRequestRef);

      final senderRequestRef = senderUserRef.collection('requests').doc(currentUser.uid);
      transaction.delete(senderRequestRef);

      transaction.update(myUserRef, {'followersCount': FieldValue.increment(1)});
      transaction.update(senderUserRef, {'followingCount': FieldValue.increment(1)});

      if (notificationId != null) {
         final notificationRef = myUserRef.collection('notifications').doc(notificationId);
         transaction.update(notificationRef, {'status': 'accepted', 'isRead': true});
      }
    });

    if (notificationId == null) {
      final notificationQuery = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .where('type', isEqualTo: 'follow_request')
        .where('senderId', isEqualTo: senderId)
        .where('status', isEqualTo: 'pending')
        .get();

      final batch = _firestore.batch();
      for (var doc in notificationQuery.docs) {
        batch.update(doc.reference, {'status': 'accepted', 'isRead': true});
      }
      if (notificationQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    }
  }

  Future<void> rejectFollowRequest(String senderId, String notificationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();

    final myRequestRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('requests')
        .doc(senderId);
    batch.delete(myRequestRef);

    final senderRequestRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('requests')
        .doc(currentUser.uid);
    batch.delete(senderRequestRef);
    
    final notificationRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .doc(notificationId);
    
    batch.update(notificationRef, {'status': 'rejected', 'isRead': true});

    await batch.commit();
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.runTransaction((transaction) async {
      final myUserRef = _firestore.collection('users').doc(currentUser.uid);
      final myFollowingRef = myUserRef.collection('following').doc(targetUserId);

      final followingDoc = await transaction.get(myFollowingRef);
      if (!followingDoc.exists) return;

      transaction.delete(myFollowingRef);

      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      final targetFollowerRef = targetUserRef.collection('followers').doc(currentUser.uid);

      transaction.delete(targetFollowerRef);

      transaction.update(myUserRef, {'followingCount': FieldValue.increment(-1)});
      transaction.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});
    });
  }
}
