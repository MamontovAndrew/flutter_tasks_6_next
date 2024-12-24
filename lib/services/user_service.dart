import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  Future<bool> isAdmin() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      return false;
    }

    final doc = await firestore.collection('users').doc(userId).get();
    return doc.data()?['isAdmin'] ?? false;
  }

  Future<String> getAdminId() async {
    final query = await firestore.collection('users').where('isAdmin', isEqualTo: true).limit(1).get();
    if (query.docs.isEmpty) throw Exception("Администратор не найден");
    return query.docs.first.id;
  }
}
