import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class LoginStaff extends StatefulWidget {
	final VoidCallback onLogin;
	const LoginStaff({super.key, required this.onLogin});

	@override
	State<LoginStaff> createState() => _LoginStaffState();
}

class _LoginStaffState extends State<LoginStaff> {
		bool _loading = false;

		Future<void> _register() async {
			if (!_formKey.currentState!.validate()) return;
			setState(() { _loading = true; });
			try {
				final url = Uri.parse('http://localhost/employee/infoStaff.php');
				final response = await http.post(
					url,
					headers: {'Content-Type': 'application/json'},
					body: jsonEncode({
						'action': 'register',
						'username': username,
						'password': password,
					}),
				);
				final resp = jsonDecode(response.body);
				if (resp['status'] == 'success') {
					if (mounted) {
						ScaffoldMessenger.of(context).showSnackBar(
							SnackBar(content: Text(resp['message'] ?? 'สมัครสมาชิกสำเร็จ')),
						);
					}
				} else {
					if (mounted) {
						ScaffoldMessenger.of(context).showSnackBar(
							SnackBar(content: Text(resp['message'] ?? 'สมัครสมาชิกไม่สำเร็จ')),
						);
					}
				}
			} catch (e) {
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
					);
				}
			}
			setState(() { _loading = false; });
		}
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
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Expanded(
										child: ElevatedButton(
											onPressed: _loading
													? null
													: () async {
															if (_formKey.currentState!.validate()) {
																setState(() { _loading = true; });
																try {
																	final url = Uri.parse('http://localhost/employee/infoStaff.php');
																	final response = await http.post(
																		url,
																		headers: {'Content-Type': 'application/json'},
																		body: jsonEncode({
																			'action': 'login',
																			'username': username,
																			'password': password,
																		}),
																	);
																	final resp = jsonDecode(response.body);
																	if (resp['status'] == 'success') {
																		widget.onLogin();
																	} else {
																		if (mounted) {
																			ScaffoldMessenger.of(context).showSnackBar(
																				SnackBar(content: Text(resp['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ')),
																			);
																		}
																	}
																} catch (e) {
																	if (mounted) {
																		ScaffoldMessenger.of(context).showSnackBar(
																			SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
																		);
																	}
																}
																setState(() { _loading = false; });
															}
														},
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.deepPurple,
												foregroundColor: Colors.white,
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
												padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
											),
											child: _loading
													? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
													: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18)),
										),
									),
									const SizedBox(width: 16),
									Expanded(
										child: OutlinedButton(
											onPressed: _loading ? null : _register,
											style: OutlinedButton.styleFrom(
												foregroundColor: Colors.deepPurple,
												side: const BorderSide(color: Colors.deepPurple),
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
												padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
											),
											child: _loading
													? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
													: const Text('สมัครสมาชิก', style: TextStyle(fontSize: 18)),
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}
}
