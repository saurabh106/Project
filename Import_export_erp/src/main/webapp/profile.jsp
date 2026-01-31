<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
model.UserPojo user = (model.UserPojo) session.getAttribute("userProfile");

if (user == null) {
	response.sendRedirect("login.jsp");
	return;
}

String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Profile | Import Export ERP</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
	gap: 8px;
	color: white;
	text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	height: 80%;
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

/* Main Container */
.container-custom {
	max-width: 1200px;
	margin: 0 auto;
	padding: 2rem;
	min-height: calc(100vh - 80px);
	display: flex;
	align-items: center;
	justify-content: center;
}

/* Card Styling */
.card-custom {
	background: white;
	border-radius: 22px;
	padding: 3rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	box-shadow: var(--card-shadow);
	width: 100%;
	max-width: 600px;
	transition: all 0.3s ease;
}

.card-custom:hover {
	box-shadow: var(--hover-shadow);
}

.card-header {
	margin-bottom: 1rem;
	text-align: center;
}

.profile-icon {
	width: 100px;
	height: 100px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-medium));
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 auto 1.5rem;
	box-shadow: 0 12px 30px rgba(138, 86, 172, 0.25);
}

.profile-icon i {
	color: white;
	font-size: 2.5rem;
}

.card-title {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 2rem;
	margin-bottom: 0.5rem;
}

.card-subtitle {
	color: var(--text-light);
	font-size: 1.1rem;
}

/* Form Styling */


.form-label {
	color: var(--text-dark);
	font-weight: 600;
	
	font-size: 1rem;
	display: block;
}

.input-group-custom {
	position: relative;
	display: flex;
	align-items: center;
}

.input-group-custom .input-group-text {
	background: rgba(138, 86, 172, 0.1);
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-right: none;
	color: var(--lavender-primary);
	padding: 0 18px;
	height: 56px;
	border-radius: 14px 0 0 14px;
	font-size: 1.2rem;
	min-width: 60px;
	justify-content: center;
}

.form-control-custom {
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-left: none;
	border-radius: 0 14px 14px 0;
	padding: 16px 20px;
	font-size: 1rem;
	transition: all 0.3s ease;
	background: white;
	height: 56px;
	flex: 1;
}

.form-control-custom:focus {
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
	outline: none;
}

/* Button Styling */
.btn-primary-custom {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-deep));
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
	margin-top: 2rem;
}

.btn-primary-custom:hover {
	transform: translateY(-3px);
	box-shadow: 0 12px 25px rgba(138, 86, 172, 0.3);
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	color: white;
}

/* Alert Messages */
.alert-custom {
	background: rgba(16, 185, 129, 0.1);
	border: 1px solid rgba(16, 185, 129, 0.2);
	border-left: 4px solid #10b981;
	color: #047857;
	border-radius: 14px;
	padding: 1.2rem 1.5rem;
	margin-bottom: 2rem;
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 500;
}

.alert-custom i {
	font-size: 1.2rem;
}

/* Password Update Link */
.password-update {
	text-align: center;
	margin-top: 2rem;
	padding-top: 2rem;
	border-top: 1px solid rgba(138, 86, 172, 0.1);
}

.password-link {
	color: var(--lavender-primary);
	text-decoration: none;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.3s ease;
}

.password-link:hover {
	color: var(--lavender-deep);
	text-decoration: none;
	transform: translateX(5px);
}

/* Responsive */
@media ( max-width : 768px) {
	.container-custom {
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
	.profile-icon {
		width: 80px;
		height: 80px;
	}
	.profile-icon i {
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
	.form-control-custom, .input-group-custom .input-group-text {
		height: 50px;
	}
}

/* Animation */
@
keyframes fadeIn {from { opacity:0;
	transform: translateY(30px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.card-custom {
	animation: fadeIn 0.6s ease-out forwards;
}
</style>
</head>

<body>

	<!-- NAVBAR -->
	<nav class="navbar navbar-custom">
		<div class="container-fluid">
			<span class="navbar-brand text-white"> <i class="fa-solid fa-user"></i>
				Import Export ERP
			</span> <a href="ProductController" class="btn-outline-light-custom"> <i
				class="fa-solid fa-arrow-left"></i> Back to Dashboard
			</a>
		</div>
	</nav>

	<div class="container-custom">
		<div class="card-custom">
			<%
			if (msg != null) {
			%>
			<div class="alert-custom">
				<i class="fa-solid fa-circle-check"></i>
				<%=msg%>
			</div>
			<%
			}
			%>

			<div class="card-header">
				
				<h1 class="card-title">Update Profile</h1>
				<p class="card-subtitle">Manage your account details</p>
			</div>

			<form action="UserController" method="post">
				<input type="hidden" name="action" value="update">

				<!-- PORT ID -->
				<div class="form-group">
					<label class="form-label">Port ID</label>
					<div class="input-group-custom">
						<span class="input-group-text"> <i
							class="fa-solid fa-id-badge"></i>
						</span> <input type="text" class="form-control-custom" name="portId"
							value="<%=user.getPortId()%>" required
							placeholder="Enter Port ID">
					</div>
				</div>

				<!-- NAME -->
				<div class="form-group">
					<label class="form-label">Full Name</label>
					<div class="input-group-custom">
						<span class="input-group-text"> <i class="fa-solid fa-user"></i>
						</span> <input type="text" class="form-control-custom" name="name"
							value="<%=user.getName()%>" required
							placeholder="Enter your full name">
					</div>
				</div>

				<!-- EMAIL -->
				<div class="form-group">
					<label class="form-label">Email Address</label>
					<div class="input-group-custom">
						<span class="input-group-text"> <i
							class="fa-solid fa-envelope"></i>
						</span> <input type="email" class="form-control-custom" name="email"
							value="<%=user.getEmail()%>" required
							placeholder="Enter email address">
					</div>
				</div>

				<!-- LOCATION -->
				<div class="form-group">
					<label class="form-label">Location</label>
					<div class="input-group-custom">
						<span class="input-group-text"> <i
							class="fa-solid fa-location-dot"></i>
						</span> <input type="text" class="form-control-custom" name="location"
							value="<%=user.getLocation()%>" required
							placeholder="Enter your location">
					</div>
				</div>

				<button type="submit" class="btn-primary-custom">
					<i class="fa-solid fa-pen-to-square"></i> Update Profile
				</button>
			</form>
		</div>
	</div>

	<script>
// Add form validation and focus effects
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    const inputs = document.querySelectorAll('.form-control-custom');
    
    // Add focus effects to inputs
    inputs.forEach(input => {
        const inputGroup = input.closest('.input-group-custom');
        
        input.addEventListener('focus', function() {
            input.style.borderColor = 'var(--lavender-primary)';
            input.style.boxShadow = '0 0 0 3px rgba(138, 86, 172, 0.1)';
            
            if (inputGroup) {
                const icon = inputGroup.querySelector('.input-group-text');
                if (icon) {
                    icon.style.borderColor = 'var(--lavender-primary)';
                    icon.style.background = 'rgba(138, 86, 172, 0.15)';
                }
            }
        });
        
        input.addEventListener('blur', function() {
            input.style.borderColor = 'rgba(138, 86, 172, 0.2)';
            input.style.boxShadow = 'none';
            
            if (inputGroup) {
                const icon = inputGroup.querySelector('.input-group-text');
                if (icon) {
                    icon.style.borderColor = 'rgba(138, 86, 172, 0.2)';
                    icon.style.background = 'rgba(138, 86, 172, 0.1)';
                }
            }
        });
    });
    
    // Auto-focus on first input
    if (inputs.length > 0) {
        inputs[0].focus();
    }
    
    // Form validation
    form.addEventListener('submit', function(e) {
        let isValid = true;
        const emailInput = document.querySelector('input[name="email"]');
        
        // Basic email validation
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(emailInput.value)) {
            alert('Please enter a valid email address');
            emailInput.focus();
            isValid = false;
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
});
</script>

</body>
</html>