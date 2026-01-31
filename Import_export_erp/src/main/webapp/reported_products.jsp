<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.ReportPojo"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Reported Products | Import Export ERP</title>
<link rel="icon" type="image/png"
      href="<%= request.getContextPath() %>/assets/cruise-ship.png">
<!-- Bootstrap -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
	rel="stylesheet">

<!-- Font Awesome -->
<link
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"
	rel="stylesheet">

<!-- Font -->
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">

<style>
:root {
	/* Lavender Shades */
	--lavender-deep: #6a4c93;
	--lavender-primary: #8a56ac;
	--lavender-medium: #9d7bc3;
	--lavender-light: #b19cd9;
	--lavender-pale: #d8bfd8;
	--lavender-soft: #e6e6fa;
	--lavender-very-light: #f5f0ff;
	/* Text Colors */
	--text-dark: #2d3748;
	--text-medium: #4a5568;
	--text-light: #718096;
	/* Backgrounds */
	--bg-gradient: linear-gradient(135deg, #f5f0ff 0%, #e6e6fa 100%);
	/* Shadows */
	--card-shadow: 0 8px 25px rgba(138, 86, 172, 0.08);
	--hover-shadow: 0 15px 35px rgba(138, 86, 172, 0.15);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: 'Inter', 'Segoe UI', sans-serif;
	background: var(--bg-gradient);
	color: var(--text-dark);
	min-height: 100vh;
}

/* NAVBAR */
.navbar-custom {
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	padding: 1.2rem 2rem !important;
	box-shadow: 0 4px 20px rgba(106, 76, 147, 0.2);
	min-height: 80px !important;
	display: flex;
	align-items: center;
}

.navbar-custom .container-fluid {
	width: 100%;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 2rem !important;
	margin: 0 auto !important;
	max-width: 1400px;
}

.navbar-brand {
	font-weight: 700;
	font-size: 1.6rem !important;
	display: flex;
	align-items: center;
	gap: 12px;
	color: white;
	text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	height: 100%;
}

.navbar-brand i {
	font-size: 1.8rem !important;
	background: rgba(255, 255, 255, 0.15);
	width: 48px !important;
	height: 48px !important;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.btn-outline-light-custom {
	border: 2px solid rgba(255, 255, 255, 0.8);
	background: rgba(255, 255, 255, 0.1);
	color: white;
	font-weight: 600;
	padding: 10px 24px !important;
	border-radius: 12px;
	transition: all 0.3s ease;
	backdrop-filter: blur(10px);
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	font-size: 0.95rem;
	height: 46px;
}

.btn-outline-light-custom:hover {
	background: white;
	color: var(--lavender-deep);
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(255, 255, 255, 0.2);
}
.table {
    margin: 0;
    table-layout: auto; /* Changed from fixed if it was fixed */
    width: 100%;
}

/* Or use fixed layout with specific widths */
.table {
    margin: 0;
    table-layout: fixed;
    width: 93%;
}
/* LAYOUT */
.container-custom {
	max-width: 1400px;
	margin: 0 auto;
	padding: 2rem;
}

/* CARD STYLING */
.card-custom {
	background: white;
	border-radius: 18px;
	padding: 2rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	box-shadow: var(--card-shadow);
	margin-bottom: 2rem;
	transition: all 0.3s ease;
}

.card-custom:hover {
	box-shadow: var(--hover-shadow);
}

/* HEADER SECTION */
.header-card {
	background: linear-gradient(135deg, rgba(138, 86, 172, 0.05),
		rgba(177, 156, 217, 0.02));
	border-left: 4px solid var(--lavender-primary);
}

.header-title {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 1.8rem;
	margin-bottom: 0.5rem;
}

.header-subtitle {
	color: var(--text-light);
	font-size: 1rem;
}

/* SEARCH BOX */
.search-box {
	position: relative;
	margin-bottom: 1.5rem;
}

.search-box input {
	width: 100%;
	padding: 14px 16px 14px 50px;
	border-radius: 12px;
	border: 2px solid rgba(138, 86, 172, 0.2);
	font-size: 0.95rem;
	transition: all 0.3s ease;
	background: white;
}

.search-box input:focus {
	outline: none;
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
}

.search-box i {
	position: absolute;
	left: 18px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--lavender-primary);
	font-size: 1.1rem;
}

/* TABLE STYLING */
.table-container {
    overflow-x: auto;
    border-radius: 12px;
    border: 1px solid rgba(138, 86, 172, 0.1);
    position: relative;
    background: white;
    overflow: hidden; /* Add this to contain hover effects */
}

.table {
    margin: 0;
    min-width: 900px;
    table-layout: auto;
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
}

.table thead {
    background: linear-gradient(135deg, var(--lavender-deep),
        var(--lavender-primary));
    color: white;
    position: sticky;
    top: 0;
    z-index: 10;
}

.table thead th {
    padding: 1rem;
    font-weight: 600;
    border: none;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

.table tbody tr {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    border-bottom: 1px solid rgba(138, 86, 172, 0.05);
    position: relative;
}

.table tbody tr:hover {
    background: rgba(138, 86, 172, 0.03);
    transform: translateX(4px);
    box-shadow: -4px 0 0 var(--lavender-primary);
}

.table tbody td {
    padding: 1rem;
    vertical-align: middle;
    border: none;
    font-size: 0.95rem;
    position: relative;
    transition: all 0.3s ease;
}

/* STATUS BADGES */
.status-badge {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 8px 16px;
	font-size: 0.85rem;
	font-weight: 600;
	border-radius: 20px;
	letter-spacing: 0.3px;
	border: 1px solid transparent;
	min-width: 100px;
	justify-content: center;
}

.status-open {
	background: rgba(245, 158, 11, 0.1);
	color: #b45309;
	border-color: rgba(245, 158, 11, 0.2);
}

.status-resolved {
	background: rgba(16, 185, 129, 0.1);
	color: #047857;
	border-color: rgba(16, 185, 129, 0.2);
}

/* FORM CONTROLS */
.form-select-sm {
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-radius: 10px;
	padding: 8px 12px;
	font-size: 0.85rem;
	transition: all 0.3s ease;
	background: white;
	min-width: 140px;
}

.form-select-sm:focus {
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
	outline: none;
}

.btn-update {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-deep));
	border: none;
	color: white;
	padding: 8px 20px;
	border-radius: 10px;
	font-weight: 600;
	font-size: 0.85rem;
	transition: all 0.3s ease;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 6px;
	min-width: 100px;
}

.btn-update:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(138, 86, 172, 0.25);
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
}

/* LOCKED STATUS */
.locked-status {
	color: var(--text-light);
	font-weight: 600;
	font-size: 0.9rem;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 8px 16px;
	background: rgba(138, 86, 172, 0.05);
	border-radius: 10px;
	border: 1px solid rgba(138, 86, 172, 0.1);
}

/* ALERT MESSAGES */
.alert-custom {
	border: none;
	border-radius: 14px;
	padding: 1.2rem 1.5rem;
	margin-bottom: 1.5rem;
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 500;
}

.alert-success-custom {
	background: rgba(16, 185, 129, 0.1);
	color: #047857;
	border-left: 4px solid #10b981;
}

.alert-danger-custom {
	background: rgba(239, 68, 68, 0.1);
	color: #dc2626;
	border-left: 4px solid #ef4444;
}

.alert-info-custom {
	background: rgba(59, 130, 246, 0.1);
	color: #1d4ed8;
	border-left: 4px solid #3b82f6;
}

.alert-custom i {
	font-size: 1.2rem;
}

/* EMPTY STATE */
.empty-state {
	text-align: center;
	padding: 3rem;
	color: var(--text-light);
}

.empty-state i {
	font-size: 3rem;
	color: var(--lavender-light);
	margin-bottom: 1rem;
	opacity: 0.5;
}

/* REPORT ID STYLING */
.report-id {
	color: var(--lavender-medium);
	font-weight: 700;
	font-size: 0.95rem;
}

.product-id {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 1rem;
}

/* REASON STYLING */
.reason-text {
	color: var(--text-dark);
	max-width: 300px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

/* PAGINATION STYLING */
.pagination-custom {
	display: flex;
	justify-content: center;
	align-items: center;
	gap: 8px;
	margin-top: 2rem;
	padding-top: 1.5rem;
	border-top: 1px solid rgba(138, 86, 172, 0.1);
}

.pagination-custom .page-item {
	margin: 0 2px;
}

.pagination-custom .page-link {
	background: white;
	border: 2px solid rgba(138, 86, 172, 0.2);
	color: var(--lavender-medium);
	font-weight: 600;
	padding: 8px 16px;
	border-radius: 10px;
	min-width: 42px;
	text-align: center;
	transition: all 0.3s ease;
}

.pagination-custom .page-link:hover {
	background: rgba(138, 86, 172, 0.05);
	border-color: var(--lavender-primary);
	color: var(--lavender-deep);
	transform: translateY(-2px);
}

.pagination-custom .page-item.active .page-link {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-deep));
	color: white;
	border-color: var(--lavender-primary);
}

.pagination-custom .page-item.disabled .page-link {
	background: rgba(138, 86, 172, 0.05);
	color: var(--text-light);
	border-color: rgba(138, 86, 172, 0.1);
	cursor: not-allowed;
	transform: none;
}

.pagination-info {
	text-align: center;
	color: var(--text-medium);
	font-size: 0.9rem;
	margin-top: 1rem;
	font-weight: 500;
}

/* RESPONSIVE */
@media ( max-width : 768px) {
	.container-custom {
		padding: 1rem;
	}
	.card-custom {
		padding: 1.5rem;
	}
	.navbar-custom {
		padding: 1rem !important;
	}
	.navbar-custom .container-fluid {
		padding: 0 1rem !important;
	}
	.table-container {
		margin: 0 -1rem;
	}
	.status-badge {
		min-width: 90px;
		padding: 6px 12px;
		font-size: 0.8rem;
	}
	.pagination-custom .page-link {
		padding: 6px 12px;
		min-width: 36px;
		font-size: 0.85rem;
	}
}

@media ( max-width : 480px) {
	.navbar-brand {
		font-size: 1.3rem !important;
	}
	.navbar-brand i {
		width: 40px !important;
		height: 40px !important;
		font-size: 1.5rem !important;
	}
	.btn-outline-light-custom {
		padding: 8px 16px !important;
		font-size: 0.85rem;
	}
	.header-title {
		font-size: 1.5rem;
	}
	.pagination-custom {
		flex-wrap: wrap;
	}
	.pagination-custom .page-link {
		padding: 4px 10px;
		min-width: 32px;
		font-size: 0.8rem;
	}
}

/* ANIMATIONS */
@
keyframes fadeIn {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.card-custom {
	animation: fadeIn 0.5s ease-out forwards;
}

/* NO SCROLLING */
html, body {
	overflow-x: hidden;
}
</style>
</head>

<body>

	<!-- NAVBAR -->
	<nav class="navbar navbar-custom">
		<div class="container-fluid">
			<span class="navbar-brand text-white"> <i
				class="fa-solid fa-triangle-exclamation"></i> Import Export ERP
			</span> <a href="ProductController" class="btn-outline-light-custom"> <i
				class="fa-solid fa-arrow-left"></i> Back to Dashboard
			</a>
		</div>
	</nav>

	<div class="container-custom">

		<!-- ALERT MESSAGES -->
		<%
		String msg = request.getParameter("msg");
		String error = request.getParameter("error");
		if (msg != null) {
		%>
		<div class="alert-custom alert-success-custom">
			<i class="fa-solid fa-circle-check"></i>
			<%=msg%>
		</div>
		<%
		} else if (error != null) {
		%>
		<div class="alert-custom alert-danger-custom">
			<i class="fa-solid fa-triangle-exclamation"></i>
			<%=error%>
		</div>
		<%
		}
		%>

		<!-- HEADER -->
		<div class="card-custom header-card">
			<h2 class="header-title">Reported Products</h2>
			<p class="header-subtitle">Review and resolve reported product
				issues</p>
		</div>

		<%
		List<ReportPojo> reports = (List<ReportPojo>) request.getAttribute("reports");
		
		// Pagination parameters
		int pageNumber = 1;
		int pageSize = 10; // Items per page
		int totalReports = 0;
		int totalPages = 1;
		int startIndex = 0;
		int endIndex = 0;
		
		// Get pagination parameters from request
		String pageParam = request.getParameter("page");
		if (pageParam != null && !pageParam.isEmpty()) {
			try {
				pageNumber = Integer.parseInt(pageParam);
				if (pageNumber < 1) pageNumber = 1;
			} catch (NumberFormatException e) {
				pageNumber = 1;
			}
		}
		
		List<ReportPojo> currentPageReports = new ArrayList<>();
		
		if (reports != null) {
			totalReports = reports.size();
			
			// Calculate pagination
			totalPages = (int) Math.ceil((double) totalReports / pageSize);
			if (pageNumber > totalPages) pageNumber = totalPages;
			if (pageNumber < 1) pageNumber = 1;
			
			// Calculate start and end indices for current page
			startIndex = (pageNumber - 1) * pageSize;
			endIndex = Math.min(startIndex + pageSize, totalReports);
			
			// Get sublist for current page
			if (startIndex < totalReports) {
				currentPageReports = reports.subList(startIndex, endIndex);
			}
		} else {
			// Initialize empty list if reports is null
			reports = new ArrayList<>();
		}
		%>

		<!-- REPORTS TABLE -->
		<div class="card-custom">
			<div class="search-box">
				<i class="fas fa-search"></i> <input type="text" id="reportSearch"
					placeholder="Search by Report ID, Product ID, Status...">
			</div>
			
			<%
			if (reports != null && !reports.isEmpty() && !currentPageReports.isEmpty()) {
			%>
			<div class="table-container">
				<table class="table table-hover align-middle">
					<thead>
						<tr>
							<th>Report ID</th>
							<th>Product ID</th>
							<th>Reason</th>
							<th>Status</th>
							<th>Action</th>
						</tr>
					</thead>

					<tbody id="reportTable">
						<%
						for (ReportPojo r : currentPageReports) {
							String status = r.getStatus();
						%>
						<tr>
							<td><span class="report-id">#<%=r.getReportId()%></span></td>
							<td><span class="product-id"><%=r.getProductId()%></span></td>
							<td><span class="reason-text" title="<%=r.getReason()%>"><%=r.getReason()%></span></td>

							<!-- STATUS BADGE -->
							<td><span
								class="status-badge <%="OPEN".equals(status) ? "status-open" : "status-resolved"%>">
									<i
									class="fa-solid <%="OPEN".equals(status) ? "fa-clock" : "fa-circle-check"%>"></i>
									<%=status%>
							</span></td>

							<!-- ACTION -->
							<td>
								<%
								if ("OPEN".equals(status)) {
								%>
								<form action="ReportController" method="post"
									class="d-flex align-items-center gap-2">
									<input type="hidden" name="action" value="resolve"> <input
										type="hidden" name="reportId" value="<%=r.getReportId()%>">

									<select name="status" class="form-select-sm">
										<option value="RESOLVED">RESOLVED</option>
									</select>

									<button type="submit" class="btn-update">
										<i class="fa-solid fa-check"></i> Resolve
									</button>
								</form> <%
 } else {
 %> <span class="locked-status"> <i class="fa-solid fa-lock"></i>
									Resolved
							</span> <%
 }
 %>
							</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
			
			<!-- PAGINATION -->
			<div class="pagination-info">
				Showing <%=totalReports > 0 ? Math.min(startIndex + 1, totalReports) : 0%> to <%=endIndex%> of <%=totalReports%> reports
			</div>
			
			<nav aria-label="Page navigation">
				<ul class="pagination pagination-custom">
					<!-- Previous Button -->
					<li class="page-item <%=pageNumber <= 1 ? "disabled" : ""%>">
						<a class="page-link" href="ReportController?page=<%=pageNumber-1%>"
							aria-label="Previous"> <span aria-hidden="true">&laquo;</span>
						</a>
					</li>
					
					<!-- Page Numbers -->
					<%
					// Show up to 5 page numbers
					int startPage = Math.max(1, pageNumber - 2);
					int endPage = Math.min(totalPages, pageNumber + 2);
					
					// Adjust if we're near the start
					if (pageNumber <= 3) {
						endPage = Math.min(5, totalPages);
					}
					
					// Adjust if we're near the end
					if (pageNumber >= totalPages - 2) {
						startPage = Math.max(1, totalPages - 4);
					}
					
					// Show first page if not in range
					if (startPage > 1) {
					%>
					<li class="page-item">
						<a class="page-link" href="ReportController?page=1">1</a>
					</li>
					<% if (startPage > 2) { %>
					<li class="page-item disabled">
						<span class="page-link">...</span>
					</li>
					<% } %>
					<%
					}
					
					for (int i = startPage; i <= endPage; i++) {
					%>
					<li class="page-item <%=i == pageNumber ? "active" : ""%>">
						<a class="page-link" href="ReportController?page=<%=i%>"><%=i%></a>
					</li>
					<%
					}
					
					// Show last page if not in range
					if (endPage < totalPages) {
						if (endPage < totalPages - 1) {
					%>
					<li class="page-item disabled">
						<span class="page-link">...</span>
					</li>
					<%
						}
					%>
					<li class="page-item">
						<a class="page-link" href="ReportController?page=<%=totalPages%>"><%=totalPages%></a>
					</li>
					<%
					}
					%>
					
					<!-- Next Button -->
					<li class="page-item <%=pageNumber >= totalPages ? "disabled" : ""%>">
						<a class="page-link" href="ReportController?page=<%=pageNumber+1%>"
							aria-label="Next"> <span aria-hidden="true">&raquo;</span>
						</a>
					</li>
				</ul>
			</nav>
			<%
			} else if (reports != null && reports.isEmpty()) {
			%>
			<div class="empty-state">
				<i class="fa-solid fa-clipboard-check"></i>
				<h5 class="mb-2">No Reports Found</h5>
				<p class="text-muted">All products are currently complaint-free.</p>
			</div>
			<%
			} else {
			%>
			<div class="empty-state">
				<i class="fa-solid fa-clipboard-check"></i>
				<h5 class="mb-2">No Reports Found</h5>
				<p class="text-muted">All products are currently complaint-free.</p>
			</div>
			<%
			}
			%>
		</div>

	</div>

	<script>
document.addEventListener('DOMContentLoaded', function() {
    // Search functionality
    const searchInput = document.getElementById('reportSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            let value = this.value.toLowerCase().trim();
            
            document.querySelectorAll("#reportTable tr").forEach(row => {
                const reportId = row.cells[0].innerText.toLowerCase();
                const productId = row.cells[1].innerText.toLowerCase();
                const status = row.cells[3].innerText.toLowerCase();
                
                if (reportId.includes(value) || productId.includes(value) || status.includes(value)) {
                    row.style.display = "";
                    row.style.animation = "fadeIn 0.3s ease";
                } else {
                    row.style.display = "none";
                }
            });
        });
        
        // Auto-focus on search box
        searchInput.focus();
    }
    
    // Add hover effects to table rows
    const tableRows = document.querySelectorAll('#reportTable tr');
    tableRows.forEach(row => {
        row.addEventListener('mouseenter', function() {
            this.style.backgroundColor = 'rgba(138, 86, 172, 0.03)';
        });
        
        row.addEventListener('mouseleave', function() {
            this.style.backgroundColor = '';
        });
    });
    
    // Add focus effects to select elements
    const selectElements = document.querySelectorAll('.form-select-sm');
    selectElements.forEach(select => {
        select.addEventListener('focus', function() {
            this.style.borderColor = 'var(--lavender-primary)';
            this.style.boxShadow = '0 0 0 3px rgba(138, 86, 172, 0.1)';
        });
        
        select.addEventListener('blur', function() {
            this.style.borderColor = 'rgba(138, 86, 172, 0.2)';
            this.style.boxShadow = 'none';
        });
    });
    
    // Add tooltip to reason text that overflows
    const reasonElements = document.querySelectorAll('.reason-text');
    reasonElements.forEach(element => {
        if (element.scrollWidth > element.clientWidth) {
            element.setAttribute('title', element.textContent);
        }
    });
    
    // Confirmation for resolving reports
    const resolveForms = document.querySelectorAll('form[action="ReportController"]');
    resolveForms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!confirm('Are you sure you want to mark this report as resolved?')) {
                e.preventDefault();
            }
        });
    });
});
</script>

</body>
</html>