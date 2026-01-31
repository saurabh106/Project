<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.OrderPojo"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Order Management | Import Export ERP</title>
<link rel="icon" type="image/png"
	href="<%=request.getContextPath()%>/assets/cruise-ship.png">
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
	min-width: 120px;
	justify-content: center;
}


/* STATUS COLORS */
.status-pending {
	background: rgba(245, 158, 11, 0.1);
	color: #b45309;
	border-color: rgba(245, 158, 11, 0.2);
}

.status-shipped {
	background: rgba(59, 130, 246, 0.1);
	color: #1d4ed8;
	border-color: rgba(59, 130, 246, 0.2);
}

.status-delivered {
	background: rgba(16, 185, 129, 0.1);
	color: #047857;
	border-color: rgba(16, 185, 129, 0.2);
}

.status-cancelled {
	background: rgba(239, 68, 68, 0.1);
	color: #dc2626;
	border-color: rgba(239, 68, 68, 0.2);
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

/* ORDER ID STYLING */
.order-id {
	color: var(--lavender-medium);
	font-weight: 700;
	font-size: 0.95rem;
}

.order-amount {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 1rem;
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
		min-width: 100px;
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
				class="fa-solid fa-cart-shopping"></i> Import Export ERP
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
			<h2 class="header-title">Order Management</h2>
			<p class="header-subtitle">Track, update, and manage all import &
				export orders</p>
		</div>

		<%
		List<OrderPojo> orders = (List<OrderPojo>) request.getAttribute("orders");
		// Pagination parameters
		int pageNumber = 1;
		int pageSize = 10; // Items per page
		int totalItems = 0;
		int totalPages = 1;

		// Get pagination parameters from request
		String pageParam = request.getParameter("page");
		if (pageParam != null && !pageParam.isEmpty()) {
			try {
				pageNumber = Integer.parseInt(pageParam);
				if (pageNumber < 1)
			pageNumber = 1;
			} catch (NumberFormatException e) {
				pageNumber = 1;
			}
		}

		// Get total items and calculate pagination
		if (orders != null) {
			totalItems = orders.size();
			totalPages = (int) Math.ceil((double) totalItems / pageSize);
			if (pageNumber > totalPages)
				pageNumber = totalPages;

			// Calculate start and end indices for current page
			int startIndex = (pageNumber - 1) * pageSize;
			int endIndex = Math.min(startIndex + pageSize, totalItems);

			// Get sublist for current page
			List<OrderPojo> currentPageOrders = orders.subList(startIndex, endIndex);
		%>

		<!-- ORDERS TABLE -->
		<div class="card-custom">
			<div class="search-box">
				<i class="fas fa-search"></i> <input type="text" id="orderSearch"
					placeholder="Search by Order ID, Buyer ID, Amount, Status...">
			</div>

			<%
			if (!currentPageOrders.isEmpty()) {
			%>

			<div class="table-container">
				<table class="table table-hover align-middle no-hover-cut">
					<thead>
						<tr>
							<th>Order ID</th>
							<th>Buyer Port ID</th>
							<th>Amount (₹)</th>
							<th>Status</th>
							<th>Created At</th>
							<th>Update Status</th>
						</tr>
					</thead>

					<tbody id="orderTable">
						<%
						for (OrderPojo o : currentPageOrders) {
							String status = o.getStatus();
						%>
						<tr>
							<td><span class="order-id">#<%=o.getOrderId()%></span></td>
							<td><strong><%=o.getBuyerId()%></strong></td>
							<td><span class="order-amount">₹ <%=o.getTotalPrice()%></span></td>

							<!-- STATUS BADGE -->
							<td><span
								class="status-badge
                                <%="PENDING".equals(status)
		? "status-pending"
		: "SHIPPED".equals(status)
				? "status-shipped"
				: "DELIVERED".equals(status)
						? "status-delivered"
						: "CANCELLED".equals(status) ? "status-cancelled" : ""%>">

									<i
									class="fa-solid
                                    <%="PENDING".equals(status)
		? "fa-clock"
		: "SHIPPED".equals(status)
				? "fa-truck-fast"
				: "DELIVERED".equals(status) ? "fa-circle-check" : "CANCELLED".equals(status) ? "fa-ban" : "fa-circle"%>"></i>

									<%=status%>
							</span></td>

							<td>
								<%
								java.sql.Timestamp timestamp = o.getCreatedAt();
								if (timestamp != null) {
									java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
									out.print(sdf.format(timestamp));
								} else {
									out.print("N/A");
								}
								%>
							</td>

							<!-- UPDATE STATUS -->
							<td>
								<%
								if ("PENDING".equals(status) || "SHIPPED".equals(status)) {
								%>
								<form action="OrderController" method="post"
									class="d-flex align-items-center gap-2 update-form">
									<input type="hidden" name="action" value="updateStatus">
									<input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
									<input type="hidden" name="currentStatus" value="<%=status%>">
									<select name="status" class="form-select-sm">
										<%
										if ("PENDING".equals(status)) {
										%>
										<option value="SHIPPED">SHIPPED</option>
										<option value="DELIVERED">DELIVERED</option>
										<option value="CANCELLED">CANCELLED</option>
										<%
										} else if ("SHIPPED".equals(status)) {
										%>
										<option value="PENDING">PENDING</option>
										<option value="DELIVERED">DELIVERED</option>
										<option value="CANCELLED">CANCELLED</option>
										<%
										}
										%>
									</select>
									<button type="button" class="btn-update update-btn">
										<i class="fa-solid fa-rotate"></i> Update
									</button>
								</form> <%
 } else {
 %> <span class="locked-status"> <i class="fa-solid fa-lock"></i>
									Locked
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
				Showing
				<%=startIndex + 1%>
				to
				<%=endIndex%>
				of
				<%=totalItems%>
				orders
			</div>

			<nav aria-label="Page navigation">
				<ul class="pagination pagination-custom">
					<!-- Previous Button -->
					<li class="page-item <%=pageNumber <= 1 ? "disabled" : ""%>">
						<a class="page-link" href="OrderController?page=<%=pageNumber - 1%>"
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
					<li class="page-item"><a class="page-link"
						href="OrderController?page=1">1</a></li>
					<%
					if (startPage > 2) {
					%>
					<li class="page-item disabled"><span class="page-link">...</span>
					</li>
					<%
					}
					%>
					<%
					}

					for (int i = startPage; i <= endPage; i++) {
					%>
					<li class="page-item <%=i == pageNumber ? "active" : ""%>"><a
						class="page-link" href="OrderController?page=<%=i%>"><%=i%></a></li>
					<%
					}

					// Show last page if not in range
					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%>
					<li class="page-item disabled"><span class="page-link">...</span>
					</li>
					<%
					}
					%>
					<li class="page-item"><a class="page-link"
						href="OrderController?page=<%=totalPages%>"><%=totalPages%></a></li>
					<%
					}
					%>

					<!-- Next Button -->
					<li
						class="page-item <%=pageNumber >= totalPages ? "disabled" : ""%>">
						<a class="page-link" href="OrderController?page=<%=pageNumber + 1%>"
						aria-label="Next"> <span aria-hidden="true">&raquo;</span>
					</a>
					</li>
				</ul>
			</nav>

			<%
			} else {
			%>
			<div class="empty-state">
				<i class="fa-solid fa-cart-shopping"></i>
				<h5 class="mb-2">No Orders Found</h5>
				<p class="text-muted">No orders have been placed for your
					account yet.</p>
			</div>
			<%
			}
			%>
		</div>

		<%
		} else {
		%>
		<div class="card-custom">
			<div class="empty-state">
				<i class="fa-solid fa-cart-shopping"></i>
				<h5 class="mb-2">No Orders Found</h5>
				<p class="text-muted">No orders have been placed for your
					account yet.</p>
			</div>
		</div>
		<%
		}
		%>

	</div>

	<!-- SEARCH SCRIPT -->
	<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('orderSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            let value = this.value.toLowerCase().trim();
            
            document.querySelectorAll("#orderTable tr").forEach(row => {
                const rowText = row.textContent.toLowerCase();
                if (rowText.includes(value)) {
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
    const tableRows = document.querySelectorAll('#orderTable tr');
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
});

document.addEventListener('DOMContentLoaded', function() {
    // Add click event to update buttons
    document.querySelectorAll('.update-btn').forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const form = this.closest('.update-form');
            const orderId = form.querySelector('input[name="orderId"]').value;
            const currentStatus = form.querySelector('input[name="currentStatus"]').value;
            const newStatus = form.querySelector('select[name="status"]').value;
            
            
            const confirmationMessage = `Are you sure you want to update Order ?\nThis action cannot be undone.`;
            
                        if (confirm(confirmationMessage)) {
            
                form.submit();
            }
            
        });
    });
});
</script>

</body>
</html>