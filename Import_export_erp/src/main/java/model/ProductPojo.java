package model;

import java.sql.Timestamp;
import java.util.List;
import Operation_implementor.ProductOperationImplementor;

public class ProductPojo {

	private int productId;
	private String productName;
	private String description;
	private int quantity;
	private double price;
	private String sellerPortId;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	public String getSellerPortId() {
		return sellerPortId;
	}

	public void setSellerPortId(String sellerPortId) {
		this.sellerPortId = sellerPortId;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public boolean addProduct(ProductPojo p) {
		return new ProductOperationImplementor().addProduct(p);
	}

	public boolean updateProduct(ProductPojo p) {
		return new ProductOperationImplementor().updateProduct(p);
	}

	public boolean deleteProduct(int productId) {
		return new ProductOperationImplementor().deleteProduct(productId);
	}

	public ProductPojo getProductById(int productId) {
		return new ProductOperationImplementor().getProductById(productId);
	}

	public List<ProductPojo> getProductsBySeller(String sellerId) {
		return new ProductOperationImplementor().getProductsBySeller(sellerId);
	}
}
