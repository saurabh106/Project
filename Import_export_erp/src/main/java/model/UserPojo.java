package model;

import Operation_implementor.UserOperationImplementor;

public class UserPojo {

	private String portId;
	private String name;
	private String email;
	private String password;
	private String location;

	public String getPortId() {
		return portId;
	}

	public void setPortId(String portId) {
		this.portId = portId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public void registerUser(UserPojo user) {
		new UserOperationImplementor().register(user);
	}

	public UserPojo loginUser(String portId, String hashedPassword) {
		return new UserOperationImplementor().login(portId, hashedPassword);
	}

	public UserPojo getUserByPortId(String portId) {
		return new UserOperationImplementor().getUserByPortId(portId);
	}

	public void updatePassword(String portId, String newPassword) {
		new UserOperationImplementor().updatePassword(portId, newPassword);
	}

	public boolean forgetPassword(String portId, String newPassword) {
		return new UserOperationImplementor().forgetPassword(portId, newPassword);
	}

	public void deleteUser(String portId) {
		new UserOperationImplementor().deleteUser(portId);
	}

	public void updateUser(String oldPortId, UserPojo user) {
		new UserOperationImplementor().updateUser(oldPortId, user);
	}
}
