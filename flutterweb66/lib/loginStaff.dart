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

		Future<void> _showRegisterDialog() async {
			String regUsername = '';
			String regPassword = '';
			String regConfirmPassword = '';
			final _registerFormKey = GlobalKey<FormState>();
			bool regLoading = false;

			await showDialog(
				context: context,
				builder: (context) {
					return StatefulBuilder(
						builder: (context, setState) {
							return AlertDialog(
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
								title: const Text('สมัครสมาชิก', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28)),
								content: Form(
									key: _registerFormKey,
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											TextFormField(
												style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
												decoration: const InputDecoration(
													labelText: 'ชื่อผู้ใช้',
													labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
													focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
												),
												onChanged: (v) => regUsername = v,
												validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
											),
											const SizedBox(height: 16),
											TextFormField(
												style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
												decoration: const InputDecoration(
													labelText: 'รหัสผ่าน',
													labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
													focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
												),
												obscureText: true,
												onChanged: (v) => regPassword = v,
												validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
											),
											const SizedBox(height: 16),
											TextFormField(
												style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
												decoration: const InputDecoration(
													labelText: 'ยืนยันรหัสผ่าน',
													labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
													focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
												),
												obscureText: true,
												onChanged: (v) => regConfirmPassword = v,
												validator: (v) {
												  if (v == null || v.isEmpty) {
													return 'กรุณายืนยันรหัสผ่าน';
												  }
												  if (v != regPassword) {
													return 'รหัสผ่านไม่ตรงกัน';
												  }
												  return null;
												},
											),
										],
									),
								),
								actions: [
									TextButton(
										onPressed: regLoading ? null : () => Navigator.pop(context),
										child: const Text('ยกเลิก', style: TextStyle(color: Colors.black)),
									),
									ElevatedButton(
										onPressed: regLoading
												? null
												: () async {
													if (_registerFormKey.currentState!.validate()) {
														setState(() { regLoading = true; });
														try {
															final url = Uri.parse('http://localhost/employee/infoStaff.php');
															final response = await http.post(
																url,
																headers: {'Content-Type': 'application/json'},
																body: jsonEncode({
																	'action': 'register',
																	'username': regUsername,
																	'password': regPassword,
																}),
															);
															final resp = jsonDecode(response.body);
															if (resp['status'] == 'success') {
																if (mounted) {
																	Navigator.pop(context);
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
														setState(() { regLoading = false; });
													}
												},
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.yellow[700],
											foregroundColor: Colors.black,
										),
										child: regLoading
												? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.yellow))
												: const Text('สมัครสมาชิก', style: TextStyle(color: Colors.black)),
									),
								],
							);
						},
					);
				},
			);
		}
	final _formKey = GlobalKey<FormState>();
	String username = '';
	String password = '';
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
									style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
								),
								const SizedBox(height: 24),
								TextFormField(
									style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
									decoration: const InputDecoration(
										labelText: 'ชื่อผู้ใช้',
										labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
										focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
									),
									onChanged: (v) => setState(() => username = v),
									validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
								),
								const SizedBox(height: 16),
								TextFormField(
									style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
									decoration: InputDecoration(
										labelText: 'รหัสผ่าน',
										labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
										focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
										suffixIcon: IconButton(
											icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.black),
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
													backgroundColor: Colors.yellow[700],
													foregroundColor: Colors.yellow[700],
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
													padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
												),
												child: _loading
														? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.yellow))
														: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18, color: Colors.black)),
											),
										),
										const SizedBox(width: 16),
										Expanded(
											child: OutlinedButton(
												onPressed: _loading ? null : _showRegisterDialog,
												style: OutlinedButton.styleFrom(
													foregroundColor: Colors.yellow,
													side: BorderSide(color: Colors.yellow[700]!),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
													padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
												),
												child: const Text('สมัครสมาชิก', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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

		bool _obscure = true;
}
