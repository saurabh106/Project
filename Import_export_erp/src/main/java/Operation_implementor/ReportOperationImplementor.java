package Operation_implementor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import Operation.ReportOperations;
import db_config.GetConnection;
import model.ReportPojo;

public class ReportOperationImplementor implements ReportOperations {

	@Override
	public List<ReportPojo> viewReportsByUser(String portId) {

		List<ReportPojo> list = new ArrayList<>();

		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{CALL sp_view_reports_by_user(?)}")) {

			cs.setString(1, portId);
			ResultSet rs = cs.executeQuery();

			while (rs.next()) {
				ReportPojo r = new ReportPojo();
				r.setReportId(rs.getInt("report_id"));
				r.setProductId(rs.getInt("product_id"));
				r.setReportedBy(rs.getString("reported_by"));
				r.setReason(rs.getString("reason"));
				r.setStatus(rs.getString("status"));
				r.setCreatedAt(rs.getTimestamp("created_at"));
				r.setResolvedAt(rs.getTimestamp("resolved_at"));
				list.add(r);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public void updateReportStatus(int reportId) {

		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{CALL sp_update_report_status(?,?)}")) {

			cs.setInt(1, reportId);
			cs.setString(2, "RESOLVED");
			cs.execute();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public List<ReportPojo> viewReportsByProduct(int productId) {

		List<ReportPojo> list = new ArrayList<>();

		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{CALL sp_view_reports_by_product(?)}")) {

			cs.setInt(1, productId);
			ResultSet rs = cs.executeQuery();

			while (rs.next()) {
				ReportPojo r = new ReportPojo();
				r.setReportId(rs.getInt("report_id"));
				r.setProductId(rs.getInt("product_id"));
				r.setReportedBy(rs.getString("reported_by"));
				r.setReason(rs.getString("reason"));
				r.setStatus(rs.getString("status"));
				r.setCreatedAt(rs.getTimestamp("created_at"));
				r.setResolvedAt(rs.getTimestamp("resolved_at"));
				list.add(r);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}
