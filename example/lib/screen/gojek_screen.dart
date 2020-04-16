import 'package:flutter/material.dart';

import 'login/login_page.dart';

class GojekScreen extends StatelessWidget {
	String appTitle = 'GOJEK FLUTTER';
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: appTitle,
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: LoginPage(appTitle: appTitle),
		);
	}
}
