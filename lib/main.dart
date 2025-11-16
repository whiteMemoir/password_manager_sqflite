import 'package:flutter/material.dart';
import 'data/db/database_helper.dart';
import 'data/models/password.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const PasswordListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final dbHelper = DatabaseHelper();
  List<Password> passwords = [];

  @override
  void initState() {
    super.initState();
    _refreshPasswordList();
  }

  Future<void> _refreshPasswordList() async {
    final data = await dbHelper.getPasswords();
    setState(() => passwords = data);
  }

  void _openForm({Password? password}) {
    final titleC = TextEditingController(text: password?.title ?? '');
    final usernameC = TextEditingController(text: password?.username ?? '');
    final passwordC = TextEditingController(text: password?.password ?? '');

    showDialog(
      context: context,
      builder: (_) {
        bool obscure = true;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(password == null ? 'Tambah Password' : 'Edit Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleC,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: usernameC,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordC,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPassword = Password(
                    id: password?.id,
                    title: titleC.text.trim(),
                    username: usernameC.text.trim(),
                    password: passwordC.text,
                  );
                  if (password == null) {
                    await dbHelper.insertPassword(newPassword);
                  } else {
                    await dbHelper.updatePassword(newPassword);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                  await _refreshPasswordList();
                },
                child: Text(password == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(int id) async {
    await dbHelper.deletePassword(id);
    await _refreshPasswordList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Manager')),
      body: passwords.isEmpty
          ? const Center(child: Text('Belum ada data'))
          : ListView.builder(
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                final item = passwords[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.username),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(password: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(item.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
