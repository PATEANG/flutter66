import 'package:flutter/material.dart';

class LoginStaff extends StatefulWidget {
	final VoidCallback onLogin;
	const LoginStaff({super.key, required this.onLogin});

	@override
	State<LoginStaff> createState() => _LoginStaffState();
}

class _LoginStaffState extends State<LoginStaff> {
	final _formKey = GlobalKey<FormState>();
	String username = '';
	String password = '';
	bool _obscure = true;

	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: 8,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
			margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
			child: Padding(
				padding: const EdgeInsets.all(32.0),
				child: Form(
					key: _formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Text(
								'เข้าสู่ระบบพนักงาน',
								style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
							),
							const SizedBox(height: 24),
							TextFormField(
								decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
								onChanged: (v) => setState(() => username = v),
								validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
							),
							const SizedBox(height: 16),
							TextFormField(
								decoration: InputDecoration(
									labelText: 'รหัสผ่าน',
									suffixIcon: IconButton(
										icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
										onPressed: () => setState(() => _obscure = !_obscure),
									),
								),
								obscureText: _obscure,
								onChanged: (v) => setState(() => password = v),
								validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
							),
							const SizedBox(height: 24),
								ElevatedButton(
									onPressed: () {
										if (_formKey.currentState!.validate()) {
											// สมมติ login สำเร็จเสมอ
											widget.onLogin();
										}
									},
									style: ElevatedButton.styleFrom(
										backgroundColor: Colors.deepPurple,
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
										padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
									),
									child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18)),
								),
						],
					),
				),
			),
		);
	}
}
