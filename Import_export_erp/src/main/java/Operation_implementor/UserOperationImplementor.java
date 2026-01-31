package Operation_implementor;

import java.sql.*;
import Operation.UserOperations;
import db_config.GetConnection;
import model.UserPojo;
import util.PasswordUtil;

public class UserOperationImplementor implements UserOperations {

	@Override
	public void register(UserPojo user) {

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_register_user(?,?,?,?,?)}")) {

			cs.setString(1, user.getPortId());
			cs.setString(2, user.getName());
			cs.setString(3, user.getEmail());
			cs.setString(4, user.getPassword()); // already hashed
			cs.setString(5, user.getLocation());

			cs.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public UserPojo login(String portId, String password) {

		UserPojo user = null;

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_login_user(?,?)}")) {

			cs.setString(1, portId);
			cs.setString(2, password);

			ResultSet rs = cs.executeQuery();

			if (rs.next()) {
				user = new UserPojo();
				user.setPortId(rs.getString("port_id"));
				user.setName(rs.getString("name"));
				user.setEmail(rs.getString("email"));
				user.setLocation(rs.getString("location"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return user;
	}

	@Override
	public UserPojo getUserByPortId(String portId) {

		UserPojo user = null;

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_get_user_by_portId(?)}")) {

			cs.setString(1, portId);
			ResultSet rs = cs.executeQuery();

			if (rs.next()) {
				user = new UserPojo();
				user.setPortId(rs.getString("port_id"));
				user.setName(rs.getString("name"));
				user.setEmail(rs.getString("email"));
				user.setLocation(rs.getString("location"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return user;
	}

	@Override
	public void updatePassword(String portId, String newPassword) {

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_update_password(?,?)}")) {

			cs.setString(1, portId);
			cs.setString(2, PasswordUtil.hashPassword(newPassword));
			cs.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public boolean forgetPassword(String portId, String newPassword) {

		boolean updated = false;

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_forget_password(?,?)}")) {

			cs.setString(1, portId);
			cs.setString(2, PasswordUtil.hashPassword(newPassword));

			updated = cs.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return updated;
	}

	@Override
	public void deleteUser(String portId) {

		try (CallableStatement cs = GetConnection.getConnection().prepareCall("{CALL sp_delete_user(?)}")) {

			cs.setString(1, portId);
			cs.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void updateUser(String oldPortId, UserPojo user) {
		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{CALL sp_update_user(?,?,?,?,?)}")) {

			cs.setString(1, oldPortId);
			cs.setString(2, user.getPortId());
			cs.setString(3, user.getName());
			cs.setString(4, user.getEmail());
			cs.setString(5, user.getLocation());
			cs.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
