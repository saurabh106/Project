package Operation;

import java.util.List;
import model.OrderPojo;

public interface OrderOperations {

	List<OrderPojo> getOrdersByUser(String buyerId);

	void updateOrderStatus(int orderId, String status);

	List<OrderPojo> viewOrdersBySeller(String sellerPortId);
}
