package Operation_implementor;

import java.sql.*;
import java.util.*;

import Operation.ProductOperations;
import db_config.GetConnection;
import model.ProductPojo;

public class ProductOperationImplementor implements ProductOperations {

	@Override
	public boolean addProduct(ProductPojo p) {

		try (Connection con = GetConnection.getConnection(); PreparedStatement ps = con.prepareStatement("""
				    INSERT INTO products
				    (product_name, description, quantity, price, seller_port_id)
				    VALUES (?,?,?,?,?)
				""")) {

			ps.setString(1, p.getProductName());
			ps.setString(2, p.getDescription());
			ps.setInt(3, p.getQuantity());
			ps.setDouble(4, p.getPrice());
			ps.setString(5, p.getSellerPortId());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean updateProduct(ProductPojo p) {

		try (Connection con = GetConnection.getConnection(); PreparedStatement ps = con.prepareStatement("""
				    UPDATE products
				    SET product_name=?, description=?, quantity=?, price=?
				    WHERE product_id=?
				""")) {

			ps.setString(1, p.getProductName());
			ps.setString(2, p.getDescription());
			ps.setInt(3, p.getQuantity());
			ps.setDouble(4, p.getPrice());
			ps.setInt(5, p.getProductId());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean deleteProduct(int productId) {

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement("DELETE FROM products WHERE product_id=?")) {

			ps.setInt(1, productId);
			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public ProductPojo getProductById(int productId) {

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT * FROM products WHERE product_id=?")) {

			ps.setInt(1, productId);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				ProductPojo p = new ProductPojo();
				p.setProductId(rs.getInt("product_id"));
				p.setProductName(rs.getString("product_name"));
				p.setDescription(rs.getString("description"));
				p.setQuantity(rs.getInt("quantity"));
				p.setPrice(rs.getDouble("price"));
				p.setSellerPortId(rs.getString("seller_port_id"));
				p.setCreatedAt(rs.getTimestamp("created_at"));
				p.setUpdatedAt(rs.getTimestamp("updated_at"));
				return p;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public List<ProductPojo> getProductsBySeller(String sellerId) {

		List<ProductPojo> list = new ArrayList<>();

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT * FROM products WHERE seller_port_id=?")) {

			ps.setString(1, sellerId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				ProductPojo p = new ProductPojo();
				p.setProductId(rs.getInt("product_id"));
				p.setProductName(rs.getString("product_name"));
				p.setDescription(rs.getString("description"));
				p.setQuantity(rs.getInt("quantity"));
				p.setPrice(rs.getDouble("price"));
				p.setSellerPortId(rs.getString("seller_port_id"));
				p.setCreatedAt(rs.getTimestamp("created_at"));
				p.setUpdatedAt(rs.getTimestamp("updated_at"));
				list.add(p);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}
