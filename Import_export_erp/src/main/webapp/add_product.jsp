<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.ProductPojo"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Products | Import Export ERP</title>
<link rel="icon" type="image/png"
	href="<%=request.getContextPath()%>/assets/cruise-ship.png">

<!-- Bootstrap -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
	rel="stylesheet">

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
	--lavender-mist: #faf9ff;
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

/* NAVBAR - Same as Dashboard */
:root {
	/* Add these variables if not already present */
	--lavender-primary: #8a56ac;
	--lavender-dark: #6a4c93;
	--text-dark: #2d3748;
}

.navbar-custom {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	padding: 1rem 2rem !important;
	/* Add !important to override Bootstrap */
	box-shadow: 0 4px 12px rgba(138, 86, 172, 0.2);
	position: sticky;
	top: 0;
	z-index: 1000;
}

.navbar-custom .navbar-brand {
	font-weight: 700;
	font-size: 1.5rem;
	display: flex;
	align-items: center;
	gap: 10px;
	color: white;
}

.navbar-custom .navbar-brand i {
	font-size: 1.8rem;
	background: rgba(255, 255, 255, 0.15); /* Add this if missing */
	width: 45px;
	height: 45px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

/* If you need the back button styled like logout */
.btn-outline-light-custom {
	border: 2px solid rgba(255, 255, 255, 0.8);
	background: rgba(255, 255, 255, 0.1);
	color: white;
	font-weight: 600;
	padding: 8px 24px;
	border-radius: 12px;
	transition: all 0.3s ease;
	backdrop-filter: blur(10px);
	text-decoration: none;
}

.btn-outline-light-custom:hover {
	background: white;
	color: var(--lavender-dark);
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(255, 255, 255, 0.2);
}
/* LAYOUT */
.container-box {
	max-width: 1400px;
	margin: auto;
	padding: 2rem;
}

/* CARDS */
.card-box {
	background: white;
	border-radius: 18px;
	padding: 2rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	margin-bottom: 2rem;
	box-shadow: var(--card-shadow);
	transition: all 0.3s ease;
}

.card-box:hover {
	box-shadow: var(--hover-shadow);
}

/* STATS */
.stat-box {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
	gap: 1.5rem;
	margin-bottom: 2.5rem;
}

.stat {
	background: white;
	padding: 1.8rem;
	border-radius: 16px;
	border: 1px solid rgba(138, 86, 172, 0.1);
	display: flex;
	align-items: center;
	gap: 20px;
	box-shadow: var(--card-shadow);
	transition: all 0.3s ease;
}

.stat:hover {
	transform: translateY(-5px);
	box-shadow: var(--hover-shadow);
}

.stat i {
	font-size: 2.2rem;
	color: var(--lavender-primary);
	background: rgba(138, 86, 172, 0.1);
	width: 60px;
	height: 60px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.stat h4 {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 2rem;
	margin-bottom: 0.2rem;
}

.stat small {
	color: var(--text-light);
	font-size: 0.9rem;
}

/* SEARCH */
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

/* TABLE */
.table-container {
	overflow-x: auto;
	border-radius: 12px;
	border: 1px solid rgba(138, 86, 172, 0.1);
}

.table {
	margin: 0;
	min-width: 900px;
}

.table thead {
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	color: white;
}

.table thead th {
	padding: 1rem;
	font-weight: 600;
	border: none;
	font-size: 0.9rem;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.table tbody tr {
	transition: all 0.2s ease;
	border-bottom: 1px solid rgba(138, 86, 172, 0.05);
}

.table tbody tr:hover {
	background: rgba(138, 86, 172, 0.03);
}

.table tbody td {
	padding: 1rem;
	vertical-align: middle;
	border: none;
	font-size: 0.95rem;
}

/* STATUS BADGES */
.status-in-stock {
	background: rgba(16, 185, 129, 0.1);
	color: #047857;
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 0.85rem;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	border: 1px solid rgba(16, 185, 129, 0.2);
}

.status-low-stock {
	background: rgba(245, 158, 11, 0.1);
	color: #b45309;
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 0.85rem;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	border: 1px solid rgba(245, 158, 11, 0.2);
}

.status-out-of-stock {
	background: rgba(239, 68, 68, 0.1);
	color: #b91c1c;
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 0.85rem;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	border: 1px solid rgba(239, 68, 68, 0.2);
}

/* ACTION BUTTONS */
.btn-action {
	border: none;
	padding: 8px 14px;
	border-radius: 10px;
	cursor: pointer;
	transition: all 0.3s ease;
	font-size: 0.9rem;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 40px;
	height: 40px;
}

.btn-edit {
	background: rgba(138, 86, 172, 0.1);
	color: var(--lavender-primary);
}

.btn-edit:hover {
	background: rgba(138, 86, 172, 0.2);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(138, 86, 172, 0.15);
}

.btn-delete {
	background: rgba(239, 68, 68, 0.1);
	color: #dc2626;
}

.btn-delete:hover {
	background: rgba(239, 68, 68, 0.2);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15);
}

/* FORM STYLES */
.form-control {
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-radius: 12px;
	padding: 12px 16px;
	font-size: 0.95rem;
	transition: all 0.3s ease;
	background: white;
}

.form-control:focus {
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
	outline: none;
}

.btn-primary-custom {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-deep));
	border: none;
	color: white;
	padding: 12px 28px;
	border-radius: 12px;
	font-weight: 600;
	transition: all 0.3s ease;
	display: inline-flex;
	align-items: center;
	gap: 10px;
}

.btn-primary-custom:hover {
	transform: translateY(-2px);
	box-shadow: 0 10px 25px rgba(138, 86, 172, 0.3);
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	color: white;
}

/* ALERT MESSAGES */
.alert {
	border: none;
	border-radius: 14px;
	padding: 1rem 1.5rem;
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 500;
	margin-bottom: 1.5rem;
}

.alert-success {
	background: rgba(16, 185, 129, 0.1);
	color: #047857;
	border-left: 4px solid #10b981;
}

.alert-danger {
	background: rgba(239, 68, 68, 0.1);
	color: #dc2626;
	border-left: 4px solid #ef4444;
}

.alert i {
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
	.container-box {
		padding: 1rem;
	}
	.stat-box {
		grid-template-columns: 1fr;
	}
	.table-container {
		margin: 0 -1rem;
	}
	.navbar-custom {
		padding: 1rem;
	}
	.navbar-brand {
		font-size: 1.2rem;
	}
	.btn-outline-light-custom {
		padding: 6px 16px;
		font-size: 0.9rem;
	}
	.pagination-custom .page-link {
		padding: 6px 12px;
		min-width: 36px;
		font-size: 0.85rem;
	}
}

@media ( max-width : 576px) {
	.card-box {
		padding: 1.5rem;
	}
	.stat {
		padding: 1.2rem;
	}
	.stat i {
		width: 50px;
		height: 50px;
		font-size: 1.8rem;
	}
	.stat h4 {
		font-size: 1.8rem;
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
.card-box, .stat {
	animation: fadeIn 0.5s ease-out forwards;
}

.stat:nth-child(2) {
	animation-delay: 0.1s;
}
</style>
</head>

<body>

	<!-- NAVBAR -->
	<nav class="navbar navbar-custom">
		<div class="container-fluid">
			<span class="navbar-brand text-white"> <i
				class="fa-solid fa-boxes-stacked"></i> Import Export ERP
			</span> <a href="ProductController" class="btn-outline-light-custom"> <i
				class="fa-solid fa-arrow-left"></i> Back to Dashboard
			</a>
		</div>
	</nav>

	<div class="container-box">

		<!-- ✅ ALERT MESSAGES -->
		<%
		String msg = request.getParameter("msg");
		String error = request.getParameter("error");
		if (msg != null) {
		%>
		<div class="alert alert-success">
			<i class="fa-solid fa-circle-check"></i>
			<%=msg%>
		</div>
		<%
		} else if (error != null) {
		%>
		<div class="alert alert-danger">
			<i class="fa-solid fa-triangle-exclamation"></i>
			<%=error%>
		</div>
		<%
		}
		%>

		<!-- HEADER -->
		<div class="card-box">
			<h4 class="fw-bold mb-2" style="color: var(--lavender-deep);">Product
				Management</h4>
			<p class="text-muted mb-0">Add, search and manage your products
				efficiently</p>
		</div>

	<%
List<ProductPojo> products = (List<ProductPojo>) request.getAttribute("products");
int totalProducts = 0;
int totalQty = 0;

// Pagination parameters
int pageNumber = 1;
int pageSize = 10; // Items per page
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

List<ProductPojo> currentPageProducts = new ArrayList<>();

if (products != null) {
    totalProducts = products.size();
    for (ProductPojo p : products) {
        totalQty += p.getQuantity();
    }
    
    // Calculate pagination
    totalPages = (int) Math.ceil((double) totalProducts / pageSize);
    if (pageNumber > totalPages) pageNumber = totalPages;
    if (pageNumber < 1) pageNumber = 1;
    
    // Calculate start and end indices for current page
    startIndex = (pageNumber - 1) * pageSize;
    endIndex = Math.min(startIndex + pageSize, totalProducts);
    
    // Get sublist for current page
    if (startIndex < totalProducts) {
        currentPageProducts = products.subList(startIndex, endIndex);
    }
} else {
    // Initialize empty list if products is null
    products = new ArrayList<>();
}
%>

		<!-- STATS -->
		<div class="stat-box">
			<div class="stat">
				<i class="fa-solid fa-box"></i>
				<div>
					<h4 class="mb-0"><%=totalProducts%></h4>
					<small class="text-muted">Total Products</small>
				</div>
			</div>
			<div class="stat">
				<i class="fa-solid fa-warehouse"></i>
				<div>
					<h4 class="mb-0"><%=totalQty%></h4>
					<small class="text-muted">Total Inventory</small>
				</div>
			</div>
		</div>

		<!-- ADD PRODUCT -->
		<div class="card-box">
			<h5 class="fw-semibold mb-3" style="color: var(--lavender-primary);">
				<i class="fa-solid fa-plus me-2"></i> Add New Product
			</h5>

			<form action="ProductController" method="post">
				<input type="hidden" name="action" value="add">

				<div class="row g-3">
					<div class="col-md-4">
						<input type="text" name="productName" class="form-control"
							placeholder="Product Name" required>
					</div>
					<div class="col-md-4">
						<input type="text" name="description" class="form-control"
							placeholder="Description">
					</div>
					<div class="col-md-2">
						<input type="number" name="quantity" class="form-control"
							placeholder="Quantity" min="0" required>
					</div>
					<div class="col-md-2">
						<input type="number" name="price" class="form-control"
							placeholder="Price ₹" min="0" step="0.01" required>
					</div>
				</div>

				<button class="btn-primary-custom mt-3">
					<i class="fa-solid fa-plus"></i> Add Product
				</button>
			</form>
		</div>

		<!-- PRODUCTS TABLE -->
		<div class="card-box">
			<h5 class="fw-semibold mb-3" style="color: var(--lavender-primary);">Your
				Products</h5>

			<div class="search-box">
				<i class="fas fa-search"></i> <input type="text" id="productSearch"
					placeholder="Search products by name or ID...">
			</div>

			<%
			if (products != null && !products.isEmpty()) {
			%>
			<div class="table-container">
				<table class="table table-hover align-middle">
					<thead>
						<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Description</th>
							<th>Qty</th>
							<th>Price ₹</th>
							<th>Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody id="productTable">
						<%
						for (ProductPojo p : currentPageProducts) {
							String status = p.getQuantity() == 0
							? "status-out-of-stock"
							: p.getQuantity() <= 10 ? "status-low-stock" : "status-in-stock";
						%>
						<tr>
							<td><span class="fw-semibold"
								style="color: var(--lavender-medium);">#<%=p.getProductId()%></span></td>
							<td><strong><%=p.getProductName()%></strong></td>
							<td><%=p.getDescription()%></td>
							<td><span class="fw-semibold"><%=p.getQuantity()%></span></td>
							<td><span class="fw-semibold"
								style="color: var(--lavender-deep);">₹<%=(long) p.getPrice()%></span></td>
							<td><span class="<%=status%>"> <i
									class="fa-solid
                                    <%=status.equals("status-in-stock")
		? "fa-circle-check"
		: status.equals("status-low-stock") ? "fa-triangle-exclamation" : "fa-circle-xmark"%>">
								</i> <%=status.equals("status-in-stock")
		? "In Stock"
		: status.equals("status-low-stock") ? "Low Stock" : "Out of Stock"%>
							</span></td>
							<td>
								<div class="d-flex gap-2">
									<form action="ProductController" method="post"
										style="display: inline">
										<input type="hidden" name="action" value="edit"> <input
											type="hidden" name="productId" value="<%=p.getProductId()%>">
										<button type="submit" class="btn-action btn-edit" title="Edit">
											<i class="fa-solid fa-pen"></i>
										</button>
									</form>

									<form action="ProductController" method="post"
										style="display: inline"
										onsubmit="return confirm('Are you sure you want to delete this product? This action cannot be undone.')">
										<input type="hidden" name="action" value="delete"> <input
											type="hidden" name="productId" value="<%=p.getProductId()%>">
										<button type="submit" class="btn-action btn-delete"
											title="Delete">
											<i class="fa-solid fa-trash"></i>
										</button>
									</form>
								</div>
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
    Showing <%=totalProducts > 0 ? Math.min(startIndex + 1, totalProducts) : 0%> to <%=endIndex%> of <%=totalProducts%> products
</div>

			<nav aria-label="Page navigation">
				<ul class="pagination pagination-custom">
					<!-- Previous Button -->
					<li class="page-item <%=pageNumber <= 1 ? "disabled" : ""%>">
						<a class="page-link"
						href="ProductController?page=<%=pageNumber - 1%>"
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
						href="ProductController?page=1">1</a></li>
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
						class="page-link" href="ProductController?page=<%=i%>"><%=i%></a>
					</li>
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
						href="ProductController?page=<%=totalPages%>"><%=totalPages%></a>
					</li>
					<%
					}
					%>

					<!-- Next Button -->
					<li
						class="page-item <%=pageNumber >= totalPages ? "disabled" : ""%>">
						<a class="page-link"
						href="ProductController?page=<%=pageNumber + 1%>" aria-label="Next">
							<span aria-hidden="true">&raquo;</span>
					</a>
					</li>
				</ul>
			</nav>

			<%
			} else {
			%>
			<div class="empty-state">
				<i class="fa-solid fa-box-open"></i>
				<h5 class="mb-2">No products found</h5>
				<p class="text-muted">Start by adding your first product above</p>
			</div>
			<%
			}
			%>
		</div>

	</div>

	<script>
// Search functionality
document.getElementById("productSearch").addEventListener("keyup", function () {
    let value = this.value.toLowerCase().trim();
    
    document.querySelectorAll("#productTable tr").forEach(row => {
        let productId = row.cells[0].innerText.toLowerCase();
        let productName = row.cells[1].innerText.toLowerCase();
        
        if (productId.includes(value) || productName.includes(value)) {
            row.style.display = "";
            row.style.animation = "fadeIn 0.3s ease";
        } else {
            row.style.display = "none";
        }
    });
});

// Add focus animation to form inputs
document.addEventListener('DOMContentLoaded', function() {
    const inputs = document.querySelectorAll('.form-control');
    inputs.forEach(input => {
        input.addEventListener('focus', function() {
            this.style.borderColor = 'var(--lavender-primary)';
            this.style.boxShadow = '0 0 0 3px rgba(138, 86, 172, 0.1)';
        });
        
        input.addEventListener('blur', function() {
            this.style.borderColor = 'rgba(138, 86, 172, 0.2)';
            this.style.boxShadow = 'none';
        });
    });
    
    // Auto-focus on search box
    const searchBox = document.getElementById('productSearch');
    if (searchBox) {
        searchBox.focus();
    }
});

// Smooth scroll to top
function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Show scroll to top button when scrolling
window.addEventListener('scroll', function() {
    const scrollBtn = document.getElementById('scrollTopBtn');
    if (scrollBtn) {
        if (window.scrollY > 300) {
            scrollBtn.style.display = 'block';
        } else {
            scrollBtn.style.display = 'none';
        }
    }
});
</script>

</body>
</html>