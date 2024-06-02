import 'package:supabase/supabase.dart';
import 'database_helper.dart';
import 'app_config.dart';

class SyncHelper {
  final SupabaseClient supabaseClient = SupabaseClient(AppConfig.supabaseUrl, AppConfig.supabaseAnonKey);

  Future<void> syncData() async {
    // Ambil data dari database lokal
    List<Map<String, dynamic>> localData = await DatabaseHelper().getTodoItems();

    // Kirim data ke Supabase
    final response = await supabaseClient
        .from('todos')
        .upsert(localData)
        .execute();

    if (response.error == null) {
      // Sinkronisasi berhasil
      print('Sync successful');
    } else {
      // Gagal sinkronisasi
      throw Exception('Failed to sync data: ${response.error!.message}');
    }
  }
}
