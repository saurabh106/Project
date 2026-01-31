<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Login | Import Export ERP</title>
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
	--text-dark: #2d3748;
	--text-light: #718096;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

html, body {
	height: 100%;
	width: 100%;
	overflow: hidden;
}

body {
	background: linear-gradient(135deg, #f5f0ff 0%, #e6e6fa 100%);
	font-family: 'Inter', 'Segoe UI', sans-serif;
	display: flex;
	align-items: center;
	justify-content: center;
}

.horizontal-container {
	display: flex;
	width: 90%;
	max-width: 1000px;
	height: 85vh;
	min-height: 550px;
	border-radius: 25px;
	overflow: hidden;
	box-shadow: 0 20px 60px rgba(138, 86, 172, 0.3);
}

.left-side {
	flex: 1;
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	padding: 40px;
	display: flex;
	flex-direction: column;
	justify-content: center;
	color: white;
	position: relative;
}

.right-side {
	flex: 1;
	background: white;
	padding: 40px;
	display: flex;
	flex-direction: column;
	justify-content: center;
	overflow: hidden;
}

.welcome-text {
	font-size: 32px;
	font-weight: 700;
	margin-bottom: 20px;
	line-height: 1.2;
}

.features-list {
	list-style: none;
	margin: 30px 0;
}

.features-list li {
	margin-bottom: 15px;
	display: flex;
	align-items: center;
	font-size: 15px;
}

.features-list i {
	margin-right: 12px;
	font-size: 18px;
	background: rgba(255, 255, 255, 0.2);
	width: 32px;
	height: 32px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
}

.logo-section {
	margin-top: 40px;
	display: flex;
	align-items: center;
	gap: 15px;
}

.logo-icon {
	background: white;
	width: 50px;
	height: 50px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: var(--lavender-primary);
	font-size: 24px;
}

.logo-text {
	font-size: 22px;
	font-weight: 700;
}

.form-header {
	text-align: center;
	margin-bottom: 30px;
}

.form-icon {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-secondary));
	width: 70px;
	height: 70px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 auto 20px;
	box-shadow: 0 10px 25px rgba(138, 86, 172, 0.3);
}

.form-icon i {
	font-size: 28px;
	color: white;
}

.form-title {
	color: var(--lavender-dark);
	font-weight: 700;
	font-size: 26px;
	margin-bottom: 8px;
}

.form-subtitle {
	color: var(--text-light);
	font-size: 14px;
	margin: 0;
}

.form-group {
	margin-bottom: 20px;
	position: relative;
}

.input-with-icon {
	position: relative;
}

.input-with-icon i {
	position: absolute;
	left: 18px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--lavender-primary);
	font-size: 1.1rem;
}

.form-control {
	border: 2px solid #e2e8f0;
	border-radius: 14px;
	padding: 16px 16px 16px 50px;
	font-size: 0.95rem;
	width: 100%;
	background: white;
	transition: all 0.3s ease;
}

.form-control:focus {
	border-color: var(--lavender-primary);
	box-shadow: 0 0 0 3px rgba(138, 86, 172, 0.1);
	outline: none;
}

/* Password field with eye icon - UPDATED */
.password-field {
    position: relative;
}

.toggle-password {
    position: absolute;
    right: 45px;
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

/* Adjust padding for password input to make room for eye icon */
.password-field .form-control {
    padding-right: 45px; /* Add space for eye icon */
}

.btn-lavender {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	border: none;
	border-radius: 14px;
	padding: 16px;
	color: white;
	font-weight: 600;
	font-size: 16px;
	width: 100%;
	cursor: pointer;
	transition: all 0.3s;
	margin-top: 10px;
}

.btn-lavender:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.3);
}

.btn-outline-lavender {
	border: 2px solid var(--lavender-primary);
	border-radius: 14px;
	padding: 16px;
	color: var(--lavender-primary);
	font-weight: 600;
	font-size: 16px;
	width: 100%;
	background: white;
	cursor: pointer;
	transition: all 0.3s;
	text-decoration: none;
	display: block;
	text-align: center;
}

.btn-outline-lavender:hover {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-dark));
	color: white;
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.3);
	text-decoration: none;
}

.divider {
	text-align: center;
	margin: 20px 0;
	color: var(--text-light);
	font-size: 14px;
	position: relative;
}

.divider:before {
	content: "";
	position: absolute;
	left: 0;
	top: 50%;
	width: 45%;
	height: 1px;
	background: linear-gradient(90deg, transparent, #e2e8f0);
}

.divider:after {
	content: "";
	position: absolute;
	right: 0;
	top: 50%;
	width: 45%;
	height: 1px;
	background: linear-gradient(90deg, #e2e8f0, transparent);
}

.login-link {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	color: var(--lavender-primary);
	text-decoration: none;
	font-weight: 600;
	transition: all 0.3s;
}

.login-link:hover {
	color: var(--lavender-dark);
	text-decoration: none;
}

.error-msg {
	background: linear-gradient(135deg, #fee, #fff5f5);
	border-left: 4px solid #f56565;
	color: #c53030;
	padding: 12px 15px;
	border-radius: 10px;
	margin-bottom: 20px;
	font-weight: 500;
	font-size: 14px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.error-msg i {
	font-size: 16px;
}

.success-msg {
	background: linear-gradient(135deg, #f0fff4, #c6f6d5);
	border-left: 4px solid #48bb78;
	color: #22543d;
	padding: 12px 15px;
	border-radius: 10px;
	margin-bottom: 20px;
	font-weight: 500;
	font-size: 14px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.success-msg i {
	font-size: 16px;
}

.forgot-link {
	color: var(--lavender-primary);
	text-decoration: none;
	font-weight: 500;
	font-size: 14px;
	transition: all 0.3s ease;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

.forgot-link:hover {
	color: var(--lavender-dark);
	text-decoration: none;
}

@media ( max-width : 900px) {
	.horizontal-container {
		flex-direction: column;
		height: auto;
		max-height: 95vh;
		width: 95%;
	}
	.left-side {
		padding: 30px;
		min-height: 300px;
	}
	.right-side {
		padding: 30px;
	}
}

@media ( max-height : 700px) {
	.horizontal-container {
		height: 95vh;
		min-height: 500px;
	}
	.left-side, .right-side {
		padding: 25px;
	}
	.form-icon {
		width: 60px;
		height: 60px;
		margin-bottom: 15px;
	}
	.form-icon i {
		font-size: 24px;
	}
	.form-title {
		font-size: 22px;
	}
	.welcome-text {
		font-size: 26px;
	}
}

/* Decorative elements */
.floating-dots {
	position: absolute;
	width: 100%;
	height: 100%;
	top: 0;
	left: 0;
	pointer-events: none;
}

.dot {
	position: absolute;
	background: rgba(255, 255, 255, 0.1);
	border-radius: 50%;
}

/* No scrolling */
html, body {
	overflow: hidden !important;
	-ms-overflow-style: none;
	scrollbar-width: none;
}

.horizontal-container {
	overflow: hidden !important;
}
</style>
</head>

<body>
	<div class="horizontal-container">
		<!-- Left Side - Welcome Section -->
		<div class="left-side">
			<div class="floating-dots" id="dots"></div>
			<h1 class="welcome-text">Welcome Back to Import Export ERP</h1>
			<p style="opacity: 0.9; margin-bottom: 20px;">Sign in to continue
				managing your global trade operations</p>

			<div class="logo-section">
				<div class="logo-icon">
					<i class="fas fa-ship"></i>
				</div>
				<div class="logo-text">ImportExport ERP</div>
			</div>
		</div>

		<!-- Right Side - Login Form -->
		<div class="right-side">
			<div class="form-header">
				<div class="form-icon">
					<i class="fas fa-right-to-bracket"></i>
				</div>
				<h2 class="form-title">Sign In</h2>
				<p class="form-subtitle">Access your ERP dashboard</p>
			</div>

			<%-- Display error/success messages --%>
			<%
			String error = request.getParameter("error");
			String msg = request.getParameter("msg");
			if ("invalid".equals(error)) {
			%>
			<div class="error-msg">
				<i class="fas fa-exclamation-triangle"></i> Invalid Port ID or
				password
			</div>
			<%
			} else if ("short_password".equals(error)) {
			%>
			<div class="error-msg">
				<i class="fas fa-exclamation-triangle"></i> Password must be at
				least 6 characters
			</div>
			<%
			} else if ("password_updated".equals(msg)) {
			%>
			<div class="success-msg">
				<i class="fas fa-check-circle"></i> Password updated successfully
			</div>
			<%
			}
			%>

			<form action="UserController" method="post" id="loginForm">
				<input type="hidden" name="action" value="login">

				<div class="form-group">
					<div class="input-with-icon">
						<i class="fas fa-id-badge"></i> <input type="text" name="portId"
							class="form-control" placeholder="Port ID" required>
					</div>
				</div>

				<div class="form-group">
					<div class="input-with-icon password-field">
						<i class="fas fa-lock"></i> <input type="password" name="password"
							id="password" class="form-control" placeholder="Password"
							required>
						<button type="button" class="toggle-password" id="togglePassword">
							<i class="fas fa-eye"></i>
						</button>
					</div>
				</div>

				<div class="text-end mb-3">
					<a href="forget_password.jsp" class="forgot-link"> <i
						class="fas fa-key"></i> Forgot password?
					</a>
				</div>

				<button type="submit" class="btn btn-lavender">
					<i class="fas fa-right-to-bracket me-2"></i> Login
				</button>
			</form>

			<div class="divider">Don't have an account?</div>

			<a href="register.jsp" class="btn-outline-lavender"> <i
				class="fas fa-user-plus me-2"></i> Create New Account
			</a>
		</div>
	</div>

	<script>
        // Create decorative dots
        function createDots() {
            const dotsContainer = document.getElementById('dots');
            const dotCount = 20;
            
            for (let i = 0; i < dotCount; i++) {
                const dot = document.createElement('div');
                dot.classList.add('dot');
                
                const size = Math.random() * 8 + 4;
                dot.style.width = `${size}px`;
                dot.style.height = `${size}px`;
                
                dot.style.left = `${Math.random() * 100}%`;
                dot.style.top = `${Math.random() * 100}%`;
                
                dot.style.opacity = Math.random() * 0.3 + 0.1;
                
                dotsContainer.appendChild(dot);
            }
        }
        
        // Password visibility toggle
        function setupPasswordToggle() {
            const toggleBtn = document.getElementById('togglePassword');
            const passwordInput = document.getElementById('password');
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
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            createDots();
            setupPasswordToggle();
            
            // Add focus effects
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.style.borderColor = 'var(--lavender-primary)';
                    this.style.boxShadow = '0 0 0 3px rgba(138, 86, 172, 0.1)';
                });
                
                input.addEventListener('blur', function() {
                    this.style.borderColor = '#e2e8f0';
                    this.style.boxShadow = 'none';
                });
            });
            
            // Prevent scrolling
            document.addEventListener('wheel', function(e) {
                e.preventDefault();
            }, { passive: false });
            
            document.addEventListener('touchmove', function(e) {
                e.preventDefault();
            }, { passive: false });
            
            document.addEventListener('keydown', function(e) {
                if ([32, 33, 34, 35, 36, 37, 38, 39, 40].includes(e.keyCode)) {
                    e.preventDefault();
                }
            });
            
            // Auto-focus on Port ID field
            document.querySelector('input[name="portId"]').focus();
        });
    </script>
</body>
</html>