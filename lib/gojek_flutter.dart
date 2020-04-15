import 'dart:async';
import 'dart:core';

import 'package:uuid/uuid.dart';

import 'package:gojek_flutter/http/http.dart';
import 'package:gojek_flutter/meta/action.dart';
import 'package:gojek_flutter/meta/meta.dart';

class GojekFlutter {
	Http http = new Http();
	var uuid = Uuid();
	
	String BASE_ENDPOINT = 'https://api.gojekapi.com/';
	
	String authToken;
	
	Map<String, String> headers = { 'X-AppVersion': Meta.APP_VERSION, 'X-Location': Meta.LOCATION, 'X-PhoneModel': Meta.PHONE_MODEL, 'X-DeviceOS': Meta.DEVICE_OS };
	
	Future loginPhone(String mobile) async {
		headers['X-Uniqueid'] = uuid.v1();
		 
		Map<String, String> body = {
			'phone'				: mobile
		};
		
		http.headers = headers;
		final response = await http.post(BASE_ENDPOINT + Action.loginPhone, body: body);
		
		if (![true].contains(response['success'])) return { 'code': response['errors'][0]['code'], 'message': response['errors'][0]['message'] };
		
		return {
			'loginToken'		: response['data']['login_token']
		};
	}
	
	Future loginGojek(String loginToken, String OTP) async {
		headers['X-Uniqueid'] = uuid.v1();
		
		Map<String, String> body = {
			'scopes'			: 'gojek:customer:transaction gojek:customer:readonly',
			'grant_type'		: 'password',
			'login_token'		: loginToken,
			'otp'				: OTP,
			'client_id'			: 'gojek:cons:android',
			'client_secret'		: '83415d06-ec4e-11e6-a41b-6c40088ab51e'
		};
		
		http.headers = headers;
		final response = await http.post(BASE_ENDPOINT + Action.loginGojek, body: body);
		
		if (![true].contains(response['success'])) return { 'code': response['errors'][0]['code'], 'message': response['errors'][0]['message'] };
		
		return {
			'authToken'		: response['data']['access_token']
		};
	}
	
	Future checkBalance() async {
		headers['X-Uniqueid'] = uuid.v1();
		headers['Authorization'] = 'Bearer ' + authToken;
		
		http.headers = headers;
		final response = await http.get(BASE_ENDPOINT + Action.checkBalance);
		
		if (![true].contains(response['success'])) return { 'code': response['errors'][0]['code'], 'message': response['errors'][0]['message'] };
		
		return {};
	}
	
	Future checkWalletCode(String number) async {
		headers['X-Uniqueid'] = uuid.v1();
		headers['Authorization'] = 'Bearer ' + authToken;
		
		http.headers = headers;
		final response = await http.get(BASE_ENDPOINT + 'wallet/qr-code?phone_number=${number}');
		
		if (![true].contains(response['success'])) return { 'code': response['errors'][0]['code'], 'message': response['errors'][0]['message'] };
		
		return {
			'QRID'				: response['data']['qr_id']
		};
	}
	
	Future transferGopay(String QRID, String PIN, double amount, String description) async {
		headers['X-Uniqueid'] = uuid.v1();
		headers['Authorization'] = 'Bearer ' + authToken;
		headers['pin'] = PIN;
		headers['User-Agent'] = 'Gojek/3.34.1 (com.go-jek.ios; build:3701278; iOS 12.3.1) Alamofire/4.7.3';
		
		Map<String, String> body = {
			'qr_id'				: QRID,
			'amount'			: '${amount}',
			'description'		: description
		};
		
		http.headers = headers;
		final response = await http.post(BASE_ENDPOINT + Action.transferGopay, body: body);
		
		if (![true].contains(response['success'])) return { 'code': response['errors'][0]['code'], 'message': response['errors'][0]['message'] };
		
		return {};
	}
}
