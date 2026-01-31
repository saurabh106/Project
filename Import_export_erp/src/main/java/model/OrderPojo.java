package model;

import java.sql.Timestamp;
import java.util.List;
import Operation_implementor.OrderOperationImplementor;

public class OrderPojo {

	private int orderId;
	private int productId;
	private String buyerId;
	private int quantity;
	private int totalPrice;
	private String status;
	private Timestamp createdAt;

	public int getOrderId() {
		return orderId;
	}

	public void setOrderId(int orderId) {
		this.orderId = orderId;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getBuyerId() {
		return buyerId;
	}

	public void setBuyerId(String buyerId) {
		this.buyerId = buyerId;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public int getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(int totalPrice) {
		this.totalPrice = totalPrice;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public List<OrderPojo> getOrdersByUser(String buyerId) {
		return new OrderOperationImplementor().getOrdersByUser(buyerId);
	}

	public void updateOrderStatus(int orderId, String status) {
		new OrderOperationImplementor().updateOrderStatus(orderId, status);
	}

	public List<OrderPojo> viewOrdersBySeller(String sellerPortId) {
		return new OrderOperationImplementor().viewOrdersBySeller(sellerPortId);
	}
}
