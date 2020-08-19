import 'package:flutter_app_demo/models/user_entity.dart';

userEntityFromJson(UserEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id']?.toString();
	}
	if (json['nickname'] != null) {
		data.nickname = json['nickname']?.toString();
	}
	if (json['roles'] != null) {
		data.roles = new List<UserRole>();
		(json['roles'] as List).forEach((v) {
			data.roles.add(new UserRole().fromJson(v));
		});
	}
	if (json['state'] != null) {
		data.state = json['state']?.toInt();
	}
	if (json['token'] != null) {
		data.token = json['token']?.toString();
	}
	if (json['username'] != null) {
		data.username = json['username']?.toString();
	}
	return data;
}

Map<String, dynamic> userEntityToJson(UserEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['nickname'] = entity.nickname;
	if (entity.roles != null) {
		data['roles'] =  entity.roles.map((v) => v.toJson()).toList();
	}
	data['state'] = entity.state;
	data['token'] = entity.token;
	data['username'] = entity.username;
	return data;
}

userRoleFromJson(UserRole data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id']?.toString();
	}
	if (json['roleName'] != null) {
		data.roleName = json['roleName']?.toString();
	}
	return data;
}

Map<String, dynamic> userRoleToJson(UserRole entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['roleName'] = entity.roleName;
	return data;
}