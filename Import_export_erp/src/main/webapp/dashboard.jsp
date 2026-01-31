<%@ page import="java.util.*"%>
<%@ page
	import="model.UserPojo, model.ProductPojo, model.OrderPojo, model.ReportPojo"%>
<%@ page contentType="text/html;charset=UTF-8"%>

<%
UserPojo user = (UserPojo) session.getAttribute("userProfile");
if (user == null) {
	response.sendRedirect("login.jsp");
	return;
}

List<ProductPojo> products = (List<ProductPojo>) request.getAttribute("products");
List<OrderPojo> orders = (List<OrderPojo>) request.getAttribute("orders");
List<ReportPojo> reports = (List<ReportPojo>) request.getAttribute("reports");

int totalProducts = products != null ? products.size() : 0;
int totalOrders = orders != null ? orders.size() : 0;
int reportedProducts = reports != null ? reports.size() : 0;

int pendingOrders = 0;
if (orders != null) {
	for (OrderPojo o : orders) {
		if ("PENDING".equalsIgnoreCase(o.getStatus())) {
	pendingOrders++;
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<title>Dashboard | Import Export ERP</title>
<link rel="icon" type="image/png"
      href="<%= request.getContextPath() %>/assets/cruise-ship.png">

<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"
	rel="stylesheet">
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">

<style>
:root {
	--lavender-primary: #8a56ac;
	--lavender-secondary: #b19cd9;
	--lavender-light: #e6e6fa;
	--lavender-dark: #6a4c93;
	--accent-lavender: #d8bfd8;
	--text-dark: #2d3748;
	--text-light: #718096;
	--bg-gradient: linear-gradient(135deg, #f5f0ff 0%, #e6e6fa 100%);
	--card-shadow: 0 10px 25px rgba(138, 86, 172, 0.1);
	--hover-shadow: 0 15px 35px rgba(138, 86, 172, 0.2);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	background: var(--bg-gradient);
	font-family: 'Inter', 'Segoe UI', sans-serif;
	color: var(--text-dark);
	min-height: 100vh;
}

/* Navbar Styling */
.navbar-custom {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	padding: 1rem 2rem;
	box-shadow: 0 4px 12px rgba(138, 86, 172, 0.2);
	position: sticky;
	top: 0;
	z-index: 1000;
}

.navbar-brand {
	font-weight: 700;
	font-size: 1.5rem;
	display: flex;
	align-items: center;
	gap: 10px;
	color: white
}

.navbar-brand i {
	font-size: 1.8rem;
}

.btn-logout {
	border: 2px solid white;
	color: white;
	font-weight: 500;
	padding: 8px 20px;
	border-radius: 10px;
	transition: all 0.3s ease;
}

.btn-logout:hover {
	background: white;
	color: var(--lavender-primary);
	transform: translateY(-2px);
}

/* Dashboard Container */
.dashboard-container {
	padding: 2rem;
	max-width: 1400px;
	margin: 0 auto;
}

/* Welcome Banner */
.welcome-banner {
	background: linear-gradient(135deg, rgba(138, 86, 172, 0.1),
		rgba(177, 156, 217, 0.05));
	border-left: 4px solid var(--lavender-primary);
	border-radius: 12px;
	padding: 1.2rem 1.5rem;
	margin-bottom: 2rem;
	display: flex;
	align-items: center;
	gap: 15px;
	backdrop-filter: blur(10px);
}

.welcome-banner i {
	color: var(--lavender-primary);
	font-size: 1.4rem;
}

.welcome-banner p {
	margin: 0;
	color: var(--text-dark);
	font-weight: 500;
}

/* KPI Cards */
.kpi-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
	gap: 1.5rem;
	margin-bottom: 2.5rem;
}

.kpi-card {
	background: white;
	border-radius: 16px;
	padding: 1.5rem;
	box-shadow: var(--card-shadow);
	border: 1px solid rgba(138, 86, 172, 0.1);
	transition: all 0.3s ease;
	position: relative;
	overflow: hidden;
}

.kpi-card:hover {
	transform: translateY(-5px);
	box-shadow: var(--hover-shadow);
}

.kpi-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	width: 4px;
	height: 100%;
	background: linear-gradient(to bottom, var(--lavender-primary),
		var(--lavender-secondary));
}

.kpi-icon {
	width: 50px;
	height: 50px;
	border-radius: 12px;
	background: linear-gradient(135deg, rgba(138, 86, 172, 0.1),
		rgba(177, 156, 217, 0.05));
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 1rem;
}

.kpi-icon i {
	color: var(--lavender-primary);
	font-size: 1.3rem;
}

.kpi-label {
	font-size: 0.85rem;
	color: var(--text-light);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 0.5rem;
	font-weight: 600;
}

.kpi-value {
	font-size: 2.2rem;
	font-weight: 700;
	color: var(--lavender-dark);
	line-height: 1;
}

/* Modules Grid */
.modules-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
	gap: 1.5rem;
	margin-bottom: 2.5rem;
}

.module-card {
	background: white;
	border-radius: 18px;
	padding: 2rem;
	text-decoration: none !important;
	color: var(--text-dark);
	box-shadow: var(--card-shadow);
	border: 1px solid rgba(138, 86, 172, 0.1);
	transition: all 0.3s ease;
	text-align: center;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	min-height: 180px;
}

.module-card:hover {
	transform: translateY(-8px);
	box-shadow: var(--hover-shadow);
	color: var(--lavender-dark);
}

.module-icon {
	width: 70px;
	height: 70px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-secondary));
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 1.2rem;
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.2);
}

.module-icon i {
	color: white;
	font-size: 1.8rem;
}

.module-title {
	font-size: 1.2rem;
	font-weight: 700;
	margin-bottom: 0.5rem;
}

.module-desc {
	color: var(--text-light);
	font-size: 0.9rem;
	margin: 0;
}

/* Profile Card */
.profile-card {
	background: white;
	border-radius: 20px;
	padding: 2rem;
	box-shadow: var(--card-shadow);
	border: 1px solid rgba(138, 86, 172, 0.1);
	margin-bottom: 2rem;
}

.profile-header {
	display: flex;
	align-items: center;
	gap: 1.2rem;
	margin-bottom: 1.8rem;
	padding-bottom: 1.5rem;
	border-bottom: 1px solid rgba(138, 86, 172, 0.1);
}

.profile-avatar {
	width: 70px;
	height: 70px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-secondary));
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.2);
}

.profile-avatar i {
	color: white;
	font-size: 2rem;
}

.profile-info h5 {
	color: var(--lavender-dark);
	font-weight: 700;
	margin-bottom: 0.3rem;
}

.profile-info p {
	color: var(--text-light);
	font-size: 0.9rem;
	margin: 0;
}

/* Profile Details */
.profile-details {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
	gap: 1.5rem;
	margin-bottom: 2rem;
}

.detail-item {
	background: rgba(138, 86, 172, 0.03);
	border-radius: 12px;
	padding: 1.2rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
}

.detail-label {
	font-size: 0.85rem;
	color: var(--text-light);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 0.5rem;
	font-weight: 600;
}

.detail-value {
	font-size: 1.1rem;
	font-weight: 600;
	color: var(--lavender-dark);
}

/* Action Buttons */
.action-buttons {
	display: flex;
	gap: 1rem;
	flex-wrap: wrap;
}

.btn-update {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	border: none;
	color: white;
	padding: 10px 25px;
	border-radius: 10px;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: all 0.3s ease;
	text-decoration: none;
}

.btn-update:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.3);
	color: white;
}

.btn-delete {
	background: transparent;
	border: 2px solid #f56565;
	color: #f56565;
	padding: 10px 25px;
	border-radius: 10px;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: all 0.3s ease;
	text-decoration: none;
}

.btn-delete:hover {
	background: #f56565;
	color: white;
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(245, 101, 101, 0.2);
}

/* Footer */
.footer {
	text-align: center;
	padding: 2rem;
	color: var(--text-light);
	font-size: 0.9rem;
	border-top: 1px solid rgba(138, 86, 172, 0.1);
	margin-top: 3rem;
}

/* Responsive Design */
@media ( max-width : 768px) {
	.dashboard-container {
		padding: 1rem;
	}
	.kpi-grid, .modules-grid {
		grid-template-columns: 1fr;
	}
	.profile-details {
		grid-template-columns: 1fr;
	}
	.action-buttons {
		flex-direction: column;
	}
	.btn-update, .btn-delete {
		width: 100%;
		justify-content: center;
	}
}

@media ( max-width : 480px) {
	.navbar-custom {
		padding: 1rem;
	}
	.navbar-brand {
		font-size: 1.2rem;
	}
	.welcome-banner {
		flex-direction: column;
		text-align: center;
		gap: 10px;
	}
	.kpi-card {
		padding: 1.2rem;
	}
	.module-card {
		padding: 1.5rem;
	}
}

/* Animations */
@
keyframes fadeIn {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.kpi-card, .module-card, .profile-card {
	animation: fadeIn 0.6s ease-out forwards;
}

.kpi-card:nth-child(2) {
	animation-delay: 0.1s;
}

.kpi-card:nth-child(3) {
	animation-delay: 0.2s;
}

.kpi-card:nth-child(4) {
	animation-delay: 0.3s;
}

.module-card:nth-child(2) {
	animation-delay: 0.4s;
}

.module-card:nth-child(3) {
	animation-delay: 0.5s;
}

.profile-card {
	animation-delay: 0.6s;
}
</style>
</head>

<body>

	<!-- NAVBAR -->
	<nav class="navbar navbar-custom">
		<div class="container-fluid">
			<span class="navbar-brand text-white"> <i class="fa-solid fa-ship"></i>
				Import Export ERP
			</span> <a href="logout.jsp" class="btn btn-logout"> <i
				class="fa-solid fa-right-from-bracket"></i> Logout
			</a>
		</div>
	</nav>

	<div class="dashboard-container">

		<!-- Welcome Banner -->
		<div class="welcome-banner">
			<i class="fa-solid fa-circle-info"></i>
			<p>Welcome to your ERP dashboard. Manage products, orders, and
				reports efficiently.</p>
		</div>

		<!-- KPI Section -->
		<div class="kpi-grid">
			<div class="kpi-card">
				<div class="kpi-icon">
					<i class="fa-solid fa-boxes-stacked"></i>
				</div>
				<div class="kpi-label">Total Products</div>
				<div class="kpi-value"><%=totalProducts%></div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon">
					<i class="fa-solid fa-cart-shopping"></i>
				</div>
				<div class="kpi-label">Total Orders</div>
				<div class="kpi-value"><%=totalOrders%></div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon">
					<i class="fa-solid fa-clock"></i>
				</div>
				<div class="kpi-label">Pending Orders</div>
				<div class="kpi-value"><%=pendingOrders%></div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon">
					<i class="fa-solid fa-triangle-exclamation"></i>
				</div>
				<div class="kpi-label">Reported Products</div>
				<div class="kpi-value"><%=reportedProducts%></div>
			</div>
		</div>

		<!-- Modules Section -->
		<div class="modules-grid">
			<a href="ProductController?view=products" class="module-card">
				<div class="module-icon">
					<i class="fa-solid fa-boxes-stacked"></i>
				</div>
				<h4 class="module-title">Products</h4>
				<p class="module-desc">Manage product listings and inventory</p>
			</a> <a href="OrderController" class="module-card">
				<div class="module-icon">
					<i class="fa-solid fa-cart-shopping"></i>
				</div>
				<h4 class="module-title">Orders</h4>
				<p class="module-desc">Track import & export orders</p>
			</a> <a href="ReportController" class="module-card">
				<div class="module-icon">
					<i class="fa-solid fa-triangle-exclamation"></i>
				</div>
				<h4 class="module-title">Reports</h4>
				<p class="module-desc">Handle complaints & issues</p>
			</a>
		</div>

		<!-- Profile Section -->
		<div class="profile-card">
			<div class="profile-header">
				<div class="profile-avatar">
					<i class="fa-solid fa-user"></i>
				</div>
				<div class="profile-info">
					<h5>User Profile</h5>
					<p>Account details and settings</p>
				</div>
			</div>

			<div class="profile-details">
				<div class="detail-item">
					<div class="detail-label">Port ID</div>
					<div class="detail-value"><%=user.getPortId()%></div>
				</div>

				<div class="detail-item">
					<div class="detail-label">Full Name</div>
					<div class="detail-value"><%=user.getName()%></div>
				</div>

				<div class="detail-item">
					<div class="detail-label">Email Address</div>
					<div class="detail-value"><%=user.getEmail()%></div>
				</div>

				<div class="detail-item">
					<div class="detail-label">Location</div>
					<div class="detail-value"><%=user.getLocation()%></div>
				</div>
			</div>

			<!-- Action Buttons -->
			<div class="action-buttons">
				<a href="profile.jsp" class="btn-update"> <i
					class="fa-solid fa-pen"></i> Update Profile
				</a> <a href="delete_acc.jsp" class="btn-delete"
					onclick="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
					<i class="fa-solid fa-trash"></i> Delete Account
				</a>
			</div>
		</div>

		<!-- Footer -->
		<footer class="footer"> © 2025 Import Export ERP | Team G1 |
			All rights reserved </footer>

	</div>

	<script>
    // Add hover effects and smooth transitions
    document.addEventListener('DOMContentLoaded', function() {
        // Add click animation to module cards
        const moduleCards = document.querySelectorAll('.module-card');
        moduleCards.forEach(card => {
            card.addEventListener('click', function(e) {
                // Add ripple effect
                const ripple = document.createElement('span');
                const rect = this.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                const x = e.clientX - rect.left - size / 2;
                const y = e.clientY - rect.top - size / 2;
                
                ripple.style.cssText = `
                    position: absolute;
                    border-radius: 50%;
                    background: rgba(138, 86, 172, 0.1);
                    transform: scale(0);
                    animation: ripple 0.6s linear;
                    width: ${size}px;
                    height: ${size}px;
                    left: ${x}px;
                    top: ${y}px;
                `;
                
                this.appendChild(ripple);
                
                setTimeout(() => {
                    ripple.remove();
                }, 600);
            });
        });
        
        // Add CSS for ripple effect
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
            .module-card {
                position: relative;
                overflow: hidden;
            }
        `;
        document.head.appendChild(style);
        
        // Update KPI cards with animations
        const kpiValues = document.querySelectorAll('.kpi-value');
        kpiValues.forEach(value => {
            const originalValue = value.textContent;
            value.textContent = '0';
            
            let current = 0;
            const target = parseInt(originalValue);
            const increment = target / 30;
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    current = target;
                    clearInterval(timer);
                }
                value.textContent = Math.floor(current);
            }, 50);
        });
    });
</script>
</body>
</html>