package model;

import java.sql.Timestamp;
import java.util.List;
import Operation_implementor.ReportOperationImplementor;

public class ReportPojo {

	private int reportId;
	private int productId;
	private String reportedBy;
	private String reason;
	private String status;
	private Timestamp createdAt;
	private Timestamp resolvedAt;

	public int getReportId() {
		return reportId;
	}

	public void setReportId(int reportId) {
		this.reportId = reportId;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getReportedBy() {
		return reportedBy;
	}

	public void setReportedBy(String reportedBy) {
		this.reportedBy = reportedBy;
	}

	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
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

	public Timestamp getResolvedAt() {
		return resolvedAt;
	}

	public void setResolvedAt(Timestamp resolvedAt) {
		this.resolvedAt = resolvedAt;
	}

	public List<ReportPojo> viewReportsByUser(String portId) {
		return new ReportOperationImplementor().viewReportsByUser(portId);
	}

	public void updateReportStatus(int reportId) {
		new ReportOperationImplementor().updateReportStatus(reportId);
	}

	public List<ReportPojo> viewReportsByProduct(int productId) {
		return new ReportOperationImplementor().viewReportsByProduct(productId);
	}
}
