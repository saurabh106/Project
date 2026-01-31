<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
model.UserPojo user = (model.UserPojo) session.getAttribute("userProfile");

if (user == null) {
	response.sendRedirect("login.jsp");
	return;
}

String msg = request.getParameter("msg");
String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<title>Delete Account | Import Export ERP</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
	/* Danger Colors */
	--danger-primary: #dc2626;
	--danger-dark: #b91c1c;
	--danger-light: #fef2f2;
	/* Backgrounds */
	--bg-gradient: linear-gradient(135deg, #f5f0ff 0%, #e6e6fa 100%);
	/* Shadows */
	--card-shadow: 0 8px 25px rgba(138, 86, 172, 0.08);
	--hover-shadow: 0 15px 35px rgba(138, 86, 172, 0.15);
	--danger-shadow: 0 8px 25px rgba(220, 38, 38, 0.1);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

html, body {
	height: 100%;
	width: 100%;
	overflow: hidden !important;
}

body {
	font-family: 'Inter', 'Segoe UI', sans-serif;
	background: var(--bg-gradient);
	color: var(--text-dark);
	display: flex;
	flex-direction: column;
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

/* MAIN CONTAINER */
.main-container {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 2rem;
	overflow: hidden !important;
	max-height: calc(100vh - 80px);
}

/* CARD STYLING */
.card-custom {
	background: white;
	border-radius: 22px;
	padding: 3rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	box-shadow: var(--card-shadow);
	width: 100%;
	max-width: 500px;
	transition: all 0.3s ease;
	text-align: center;
}

.card-custom:hover {
	box-shadow: var(--hover-shadow);
}

/* WARNING ICON */
.warning-icon {
	width: 80px;
	height: 80px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--danger-primary),
		var(--danger-dark));
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 auto 1.5rem;
	box-shadow: 0 10px 30px rgba(220, 38, 38, 0.2);
	animation: pulse 2s infinite;
}

.warning-icon i {
	color: white;
	font-size: 2.2rem;
}

@
keyframes pulse { 0% {
	box-shadow: 0 10px 30px rgba(220, 38, 38, 0.2);
}

50














%
{
box-shadow














:














0














10px














40px














rgba












(














220
,
38
,
38
,
0












.3














)












;
}
100














%
{
box-shadow














:














0














10px














30px














rgba












(














220
,
38
,
38
,
0












.2














)












;
}
}

/* CARD CONTENT */
.card-title {
	color: var(--danger-primary);
	font-weight: 700;
	font-size: 1.8rem;
	margin-bottom: 1rem;
}

.card-subtitle {
	color: var(--text-light);
	font-size: 1rem;
	margin-bottom: 1.5rem;
}

.warning-message {
	background: var(--danger-light);
	border: 1px solid rgba(220, 38, 38, 0.2);
	border-radius: 14px;
	padding: 1.2rem;
	margin: 1.5rem 0;
	text-align: left;
}

.warning-message p {
	color: var(--danger-dark);
	font-size: 0.95rem;
	margin: 0;
	display: flex;
	align-items: center;
	gap: 10px;
}

.warning-message i {
	color: var(--danger-primary);
	font-size: 1.1rem;
}

.user-info {
	color: var(--lavender-deep);
	font-weight: 600;
	font-size: 1.1rem;
	margin: 1rem 0;
}

.user-name {
	color: var(--lavender-primary);
	font-weight: 700;
}

/* BUTTON STYLING */
.btn-danger-custom {
	background: linear-gradient(135deg, var(--danger-primary),
		var(--danger-dark));
	border: none;
	color: white;
	padding: 16px 32px;
	border-radius: 14px;
	font-weight: 600;
	font-size: 1.1rem;
	transition: all 0.3s ease;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 12px;
	cursor: pointer;
	width: 100%;
	margin-top: 1.5rem;
	box-shadow: var(--danger-shadow);
}

.btn-danger-custom:hover {
	transform: translateY(-3px);
	box-shadow: 0 12px 30px rgba(220, 38, 38, 0.25);
	background: linear-gradient(135deg, var(--danger-dark),
		var(--danger-primary));
	color: white;
}

/* CANCEL LINK */
.cancel-link {
	text-align: center;
	margin-top: 1.5rem;
	padding-top: 1.5rem;
	border-top: 1px solid rgba(138, 86, 172, 0.1);
}

.link-custom {
	color: var(--lavender-primary);
	text-decoration: none;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.3s ease;
}

.link-custom:hover {
	color: var(--lavender-deep);
	text-decoration: none;
	transform: translateX(-5px);
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

.alert-custom i {
	font-size: 1.2rem;
}

/* RESPONSIVE */
@media ( max-width : 768px) {
	.main-container {
		padding: 1rem;
	}
	.card-custom {
		padding: 2rem;
	}
	.navbar-custom {
		padding: 1rem !important;
	}
	.navbar-custom .container-fluid {
		padding: 0 1rem !important;
	}
	.warning-icon {
		width: 70px;
		height: 70px;
	}
	.warning-icon i {
		font-size: 2rem;
	}
	.card-title {
		font-size: 1.6rem;
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
	.card-custom {
		padding: 1.5rem;
	}
	.card-title {
		font-size: 1.4rem;
	}
	.btn-danger-custom {
		padding: 14px 24px;
		font-size: 1rem;
	}
}

/* ANIMATION */
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
	animation: fadeIn 0.6s ease-out forwards;
}

/* NO SCROLLING */
body, html, .main-container {
	-ms-overflow-style: none !important;
	scrollbar-width: none !important;
	overflow: hidden !important;
}
</style>
</head>

<body>

	<!-- MAIN CONTENT -->
	<div class="main-container">
		<div class="card-custom">
			<!-- ALERTS -->
			<%
			if (msg != null) {
			%>
			<div class="alert-custom alert-success-custom">
				<i class="fa-solid fa-circle-check"></i>
				<%=msg%>
			</div>
			<%
			}
			%>

			<%
			if (error != null) {
			%>
			<div class="alert-custom alert-danger-custom">
				<i class="fa-solid fa-triangle-exclamation"></i>
				<%=error%>
			</div>
			<%
			}
			%>

			<!-- WARNING ICON -->
			<div class="warning-icon">
				<i class="fa-solid fa-triangle-exclamation"></i>
			</div>

			<!-- CARD CONTENT -->
			<h1 class="card-title">Delete Account</h1>
			<p class="card-subtitle">This action cannot be undone</p>

			<!-- WARNING MESSAGE -->
			<div class="warning-message">
				<p>
					<i class="fa-solid fa-circle-exclamation"></i> All your data will
					be permanently deleted
				</p>
				<p>
					<i class="fa-solid fa-circle-exclamation"></i> This includes
					products, orders, and reports
				</p>
				<p>
					<i class="fa-solid fa-circle-exclamation"></i> You will not be able
					to recover your account
				</p>
			</div>

			<!-- USER INFO -->
			<div class="user-info">
				Are you sure you want to delete account for <span class="user-name"><%=user.getName()%></span>?
			</div>

			<!-- DELETE FORM -->
			<form action="UserController" method="post" id="deleteForm">
				<input type="hidden" name="action" value="delete"> <input
					type="hidden" name="portId" value="<%=user.getPortId()%>">

				<button type="submit" class="btn-danger-custom">
					<i class="fa-solid fa-trash"></i> Yes, Delete My Account
				</button>
			</form>

			<!-- CANCEL LINK -->
			<div class="cancel-link">
				<a href="dashboard.jsp" class="link-custom"> <i
					class="fa-solid fa-arrow-left"></i> Cancel and Go Back
				</a>
			</div>
		</div>
	</div>

	<script>
		// Prevent scrolling
		document
				.addEventListener(
						'DOMContentLoaded',
						function() {
							// Disable wheel scrolling
							document.addEventListener('wheel', function(e) {
								e.preventDefault();
							}, {
								passive : false
							});

							// Disable touch scrolling
							document.addEventListener('touchmove', function(e) {
								e.preventDefault();
							}, {
								passive : false
							});

							// Disable keyboard scrolling
							document.addEventListener('keydown', function(e) {
								if ([ 32, 33, 34, 35, 36, 37, 38, 39, 40 ]
										.includes(e.keyCode)) {
									e.preventDefault();
								}
							});

							// Form confirmation
							const form = document.getElementById('deleteForm');
							form
									.addEventListener(
											'submit',
											function(e) {
												const confirmMessage = "⚠️ FINAL WARNING ⚠️\n\n"
														+ "This will PERMANENTLY delete:\n"
														+ "• Your account\n"
														+ "• All your products\n"
														+ "• All your orders\n"
														+ "• All your reports\n\n"
														+ "This action CANNOT be undone!\n\n"
														+ "Type 'DELETE' to confirm:";

												const userInput = prompt(confirmMessage);

												if (userInput !== 'DELETE') {
													e.preventDefault();
													if (userInput !== null) {
														alert('Account deletion cancelled. Account was NOT deleted.');
													}
													return false;
												}

												return true;
											});

							// Add hover effect to cancel link
							const cancelLink = document
									.querySelector('.link-custom');
							if (cancelLink) {
								cancelLink
										.addEventListener(
												'mouseenter',
												function() {
													this.style.transform = 'translateX(-5px)';
												});

								cancelLink
										.addEventListener(
												'mouseleave',
												function() {
													this.style.transform = 'translateX(0)';
												});
							}
						});
	</script>

</body>
</html>