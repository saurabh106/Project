package Operation;

import model.UserPojo;

public interface UserOperations {

    void register(UserPojo user);

    UserPojo login(String portId, String password);

    UserPojo getUserByPortId(String portId);

    void updatePassword(String portId, String newPassword);

    boolean forgetPassword(String portId, String newPassword);

    void deleteUser(String portId);

    void updateUser(String oldPortId, UserPojo user);
}
