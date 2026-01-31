package Operation_implementor;

import java.sql.*;
import java.util.*;

import Operation.OrderOperations;
import db_config.GetConnection;
import model.OrderPojo;

public class OrderOperationImplementor implements OrderOperations {

    @Override
    public List<OrderPojo> getOrdersByUser(String buyerId) {
        List<OrderPojo> list = new ArrayList<>();

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL get_orders_by_user(?)}")) {

            cs.setString(1, buyerId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                OrderPojo o = new OrderPojo();
                o.setOrderId(rs.getInt("order_id"));
                o.setProductId(rs.getInt("product_id"));
                o.setQuantity(rs.getInt("quantity"));
                o.setTotalPrice(rs.getInt("total_price"));
                o.setStatus(rs.getString("order_status"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setBuyerId(buyerId);
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    @Override
    public void updateOrderStatus(int orderId, String status) {

        try (Connection con = GetConnection.getConnection();
             CallableStatement cs =
                     con.prepareCall("{CALL update_order_status(?,?)}")) {

            cs.setInt(1, orderId);
            cs.setString(2, status);
            cs.execute();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<OrderPojo> viewOrdersBySeller(String sellerPortId) {

        List<OrderPojo> list = new ArrayList<>();

        String sql = """
            SELECT o.*
            FROM orders o
            JOIN products p ON o.product_id = p.product_id
            WHERE p.seller_port_id = ?
        """;

        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, sellerPortId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderPojo o = new OrderPojo();
                o.setOrderId(rs.getInt("order_id"));
                o.setProductId(rs.getInt("product_id"));
                o.setBuyerId(rs.getString("buyer_id"));
                o.setQuantity(rs.getInt("quantity"));
                o.setTotalPrice(rs.getInt("total_price"));
                o.setStatus(rs.getString("order_status"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
