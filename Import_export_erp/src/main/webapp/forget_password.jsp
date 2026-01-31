<%@ page contentType="text/html;charset=UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Forget Password | Import Export ERP</title>
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
	align-items: center;
	justify-content: center;
	padding: 1rem;
}

/* Card Styling */
.card-custom {
	background: white;
	border-radius: 20px;
	padding: 2.5rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	box-shadow: var(--card-shadow);
	width: 100%;
	max-width: 450px;
	transition: all 0.3s ease;
}

.card-custom:hover {
	box-shadow: var(--hover-shadow);
}

/* Header Section */
.header-section {
	text-align: center;
	margin-bottom: 2rem;
}

.icon-wrapper {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-medium));
	width: 70px;
	height: 70px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 auto 1.5rem;
	box-shadow: 0 10px 25px rgba(138, 86, 172, 0.2);
}

.icon-wrapper i {
	color: white;
	font-size: 1.8rem;
}

.card-title {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 1.8rem;
	margin-bottom: 0.5rem;
}

.card-subtitle {
	color: var(--text-light);
	font-size: 1rem;
}

/* Form Styling */
.form-group {
	margin-bottom: 1.5rem;
}

.form-label {
	color: var(--text-dark);
	font-weight: 600;
	margin-bottom: 0.6rem;
	font-size: 0.95rem;
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
	padding: 0 16px;
	height: 50px;
	border-radius: 12px 0 0 12px;
	font-size: 1.1rem;
	min-width: 50px;
	justify-content: center;
}

.form-control-custom {
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-left: none;
	border-radius: 0 12px 12px 0;
	padding: 14px 16px;
	font-size: 0.95rem;
	transition: all 0.3s ease;
	background: white;
	height: 50px;
	flex: 1;
}

.form-control-custom:focus {
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
	outline: none;
}

/* Password field with eye icon */
.password-field {
	position: relative;
}

.toggle-password {
	position: absolute;
	right: 15px;
	top: 50%;
	transform: translateY(-50%);
	background: none;
	border: none;
	color: var(--lavender-primary);
	cursor: pointer;
	font-size: 16px;
	padding: 5px;
	z-index: 10;
}

.toggle-password:hover {
	color: var(--lavender-dark);
}

.password-field .form-control-custom {
	padding-right: 45px;
}

/* Button Styling */
.btn-primary-custom {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-deep));
	border: none;
	color: white;
	padding: 14px 28px;
	border-radius: 12px;
	font-weight: 600;
	font-size: 1rem;
	transition: all 0.3s ease;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	cursor: pointer;
	width: 100%;
	margin-top: 0.5rem;
}

.btn-primary-custom:hover {
	transform: translateY(-2px);
	box-shadow: 0 10px 25px rgba(138, 86, 172, 0.3);
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	color: white;
}

/* Back Link */
.back-link {
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

/* Alert Messages */
.alert-custom {
	border: none;
	border-radius: 14px;
	padding: 1rem 1.2rem;
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

/* Password Hint */
.password-hint {
	font-size: 0.8rem;
	color: var(--text-light);
	margin-top: 0.4rem;
	padding-left: 10px;
	display: flex;
	align-items: center;
	gap: 5px;
}

/* Responsive */
@media ( max-width : 576px) {
	.card-custom {
		padding: 2rem;
	}
	.icon-wrapper {
		width: 60px;
		height: 60px;
		margin-bottom: 1.2rem;
	}
	.icon-wrapper i {
		font-size: 1.5rem;
	}
	.card-title {
		font-size: 1.5rem;
	}
	.form-control-custom, .input-group-custom .input-group-text {
		height: 48px;
	}
}

/* Animation */
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
html, body {
	-ms-overflow-style: none;
	scrollbar-width: none;
	overflow: hidden !important;
}
</style>
</head>

<body>

	<div class="card-custom">
		<div class="header-section">
			<div class="icon-wrapper">
				<i class="fa-solid fa-key"></i>
			</div>
			<h1 class="card-title">Reset Password</h1>
			<p class="card-subtitle">Reset your account password securely</p>
		</div>

		<!-- ✅ Display messages -->
		<%
		String msg = request.getParameter("msg");
		String error = request.getParameter("error");

		if ("password_updated".equals(msg)) {
		%>
		<div class="alert-custom alert-success-custom">
			<i class="fa-solid fa-circle-check"></i> Password updated
			successfully. Please login.
		</div>
		<%
		} else if ("short_password".equals(error)) {
		%>
		<div class="alert-custom alert-danger-custom">
			<i class="fa-solid fa-triangle-exclamation"></i> Password must be at
			least 6 characters long.
		</div>
		<%
		} else if ("invalid_port".equals(error)) {
		%>
		<div class="alert-custom alert-danger-custom">
			<i class="fa-solid fa-triangle-exclamation"></i> Invalid Port ID.
		</div>
		<%
		}
		%>

		<form action="UserController" method="post" id="forgetForm">
			<input type="hidden" name="action" value="forget">

			<!-- Port ID -->
			<div class="form-group">
				<label class="form-label">Port ID</label>
				<div class="input-group-custom">
					<span class="input-group-text"> <i
						class="fa-solid fa-id-badge"></i>
					</span> <input type="text" class="form-control-custom" name="portId"
						id="portId" placeholder="Enter your Port ID" required>
				</div>
			</div>

			<!-- New Password -->
			<div class="form-group">
				<label class="form-label">New Password</label>
				<div class="input-group-custom password-field">
					<span class="input-group-text"> <i class="fa-solid fa-lock"></i>
					</span> <input type="password" class="form-control-custom"
						name="newPassword" id="newPassword"
						placeholder="Enter new password" required>
					<button type="button" class="toggle-password" id="togglePassword">
						<i class="fas fa-eye"></i>
					</button>
				</div>
				<div class="password-hint">
					<i class="fas fa-info-circle"></i> Must be at least 6 characters
				</div>
			</div>

			<button type="submit" class="btn-primary-custom">
				<i class="fa-solid fa-rotate"></i> Reset Password
			</button>
		</form>

		<div class="back-link">
			<a href="login.jsp" class="link-custom"> <i
				class="fa-solid fa-arrow-left"></i> Back to Login
			</a>
		</div>
	</div>

	<script>
// Prevent scrolling
document.addEventListener('DOMContentLoaded', function() {
    // Disable wheel scrolling
    document.addEventListener('wheel', function(e) {
        e.preventDefault();
    }, { passive: false });
    
    // Disable touch scrolling
    document.addEventListener('touchmove', function(e) {
        e.preventDefault();
    }, { passive: false });
    
    // Disable keyboard scrolling
    document.addEventListener('keydown', function(e) {
        if ([32, 33, 34, 35, 36, 37, 38, 39, 40].includes(e.keyCode)) {
            e.preventDefault();
        }
    });
    
    // Password visibility toggle
    const toggleBtn = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('newPassword');
    const eyeIcon = toggleBtn.querySelector('i');
    
    toggleBtn.addEventListener('click', function() {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        
        // Toggle eye icon
        if (type === 'text') {
            eyeIcon.classList.remove('fa-eye');
            eyeIcon.classList.add('fa-eye-slash');
        } else {
            eyeIcon.classList.remove('fa-eye-slash');
            eyeIcon.classList.add('fa-eye');
        }
    });
    
    // Add focus effects
    const inputs = document.querySelectorAll('.form-control-custom');
    inputs.forEach(input => {
        const inputGroup = input.closest('.input-group-custom');
        
        input.addEventListener('focus', function() {
            this.style.borderColor = 'var(--lavender-primary)';
            this.style.boxShadow = '0 0 0 3px rgba(138, 86, 172, 0.1)';
            
            if (inputGroup) {
                const icon = inputGroup.querySelector('.input-group-text');
                if (icon) {
                    icon.style.borderColor = 'var(--lavender-primary)';
                    icon.style.background = 'rgba(138, 86, 172, 0.15)';
                }
            }
        });
        
        input.addEventListener('blur', function() {
            this.style.borderColor = 'rgba(138, 86, 172, 0.2)';
            this.style.boxShadow = 'none';
            
            if (inputGroup) {
                const icon = inputGroup.querySelector('.input-group-text');
                if (icon) {
                    icon.style.borderColor = 'rgba(138, 86, 172, 0.2)';
                    icon.style.background = 'rgba(138, 86, 172, 0.1)';
                }
            }
        });
    });
    
    // Auto-focus on port ID field
    document.getElementById('portId').focus();
    
    // Form validation
    const form = document.getElementById('forgetForm');
    const passwordInput = document.getElementById('newPassword');
    
    form.addEventListener('submit', function(e) {
        if (passwordInput.value.length < 6) {
            e.preventDefault();
            alert('Password must be at least 6 characters long.');
            passwordInput.focus();
            return false;
        }
        return true;
    });
});
</script>

</body>
</html>