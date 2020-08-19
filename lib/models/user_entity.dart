import 'package:flutter_app_demo/generated/json/base/json_convert_content.dart';

class UserEntity extends JsonConvert<UserEntity> {
	String id;
	String nickname;
	List<UserRole> roles;
	int state;
	String token;
	String username;

	// 工厂模式
	factory UserEntity() =>_getInstance();
	static UserEntity get instance => _getInstance();
	static UserEntity _instance;
	UserEntity._internal() {
		// 初始化
	}
	static UserEntity _getInstance() {
		if (_instance == null) {
			_instance = new UserEntity._internal();
		}
		return _instance;
	}
}

class UserRole with JsonConvert<UserRole> {
	String id;
	String roleName;
}
