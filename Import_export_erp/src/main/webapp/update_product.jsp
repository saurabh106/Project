<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="model.ProductPojo"%>

<%
ProductPojo p = (ProductPojo) request.getAttribute("product");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<title>Update Product | Import Export ERP</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

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
	min-height: 10px !important;
	display: flex;
	align-items: center;
}

.navbar-custom .container-fluid {
	width: 100%;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 1rem !important;
	margin: 0 auto !important;
	max-width: 1400px;
}

.navbar-brand {
	font-weight: 700;
	font-size: 1.6rem !important;
	display: flex;
	align-items: center;
	gap: 6px;
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
	padding: 0.40rem;
}

/* Card Styling */
.card-custom {
	background: white;
	border-radius: 20px;
	padding: 2.5rem;
	border: 1px solid rgba(138, 86, 172, 0.1);
	box-shadow: var(--card-shadow);
	margin-top: 1rem;
	transition: all 0.3s ease;
}

.card-custom:hover {
	box-shadow: var(--hover-shadow);
}

.card-header {
	margin-bottom: 2rem;
	padding-bottom: 1.5rem;
	border-bottom: 1px solid rgba(138, 86, 172, 0.1);
}

.card-title {
	color: var(--lavender-deep);
	font-weight: 700;
	font-size: 1.8rem;
	margin-bottom: 0.5rem;
	display: flex;
	align-items: center;
	gap: 12px;
}

.card-title i {
	background: linear-gradient(135deg, var(--lavender-primary),
		var(--lavender-medium));
	color: white;
	width: 50px;
	height: 50px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.2);
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
	margin-bottom: 0.5rem;
	font-size: 0.95rem;
	display: block;
}

.form-control {
	border: 2px solid rgba(138, 86, 172, 0.2);
	border-radius: 12px;
	padding: 14px 18px;
	font-size: 1rem;
	transition: all 0.3s ease;
	background: white;
	width: 100%;
}

.form-control:focus {
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
	padding: 14px 32px;
	border-radius: 12px;
	font-weight: 600;
	font-size: 1rem;
	transition: all 0.3s ease;
	display: inline-flex;
	align-items: center;
	gap: 12px;
	cursor: pointer;
	margin-top: 1rem;
}

.btn-primary-custom:hover {
	transform: translateY(-3px);
	box-shadow: 0 12px 25px rgba(138, 86, 172, 0.3);
	background: linear-gradient(135deg, var(--lavender-deep),
		var(--lavender-primary));
	color: white;
}

.btn-secondary-custom {
	background: white;
	border: 2px solid rgba(138, 86, 172, 0.3);
	color: var(--lavender-primary);
	padding: 14px 32px;
	border-radius: 12px;
	font-weight: 600;
	font-size: 1rem;
	transition: all 0.3s ease;
	display: inline-flex;
	align-items: center;
	gap: 12px;
	cursor: pointer;
	text-decoration: none;
	margin-top: 1rem;
	margin-left: 1rem;
}

.btn-secondary-custom:hover {
	background: rgba(138, 86, 172, 0.05);
	border-color: var(--lavender-primary);
	transform: translateY(-3px);
	box-shadow: 0 8px 20px rgba(138, 86, 172, 0.15);
	color: var(--lavender-dark);
	text-decoration: none;
}

/* Responsive */
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
	.btn-primary-custom, .btn-secondary-custom {
		width: 100%;
		justify-content: center;
		margin-left: 0;
		margin-top: 0.5rem;
	}
	.button-group {
		flex-direction: column;
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
	.card-title {
		font-size: 1.5rem;
	}
	.card-title i {
		width: 40px;
		height: 40px;
		font-size: 1.2rem;
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
	animation: fadeIn 0.5s ease-out forwards;
}
</style>
</head>

<body>

	<!-- NAVBAR -->
	<nav class="navbar navbar-custom">
		<div class="container-fluid">
			<span class="navbar-brand text-white"> <i
				class="fa-solid fa-boxes-stacked"></i> Import Export ERP
			</span> <a href="ProductController?view=products"
				class="btn-outline-light-custom"> <i
				class="fa-solid fa-arrow-left"></i> Back to Products
			</a>
		</div>
	</nav>

	<div class="container-custom">
		<div class="card-custom">
			<div class="card-header">
				<h1 class="card-title">
					<i class="fa-solid fa-pen-to-square"></i> Edit Product
				</h1>
				<p class="card-subtitle">Update product details below</p>
			</div>

			<form action="ProductController" method="post">
				<input type="hidden" name="action" value="update"> <input
					type="hidden" name="productId" value="<%=p.getProductId()%>">

				<div class="form-group">
					<label class="form-label">Product Name</label> <input type="text"
						class="form-control" name="productName"
						value="<%=p.getProductName()%>" required
						placeholder="Enter product name">
				</div>

				<div class="form-group">
					<label class="form-label">Description</label> <input type="text"
						class="form-control" name="description"
						value="<%=p.getDescription()%>"
						placeholder="Enter product description">
				</div>

				<div class="row">
					<div class="col-md-6">
						<div class="form-group">
							<label class="form-label">Quantity</label> <input type="number"
								class="form-control" name="quantity"
								value="<%=p.getQuantity()%>" min="0" required
								placeholder="Enter quantity">
						</div>
					</div>
					<div class="col-md-6">
						<div class="form-group">
							<label class="form-label">Price (₹)</label> <input type="number"
								class="form-control" name="price"
								value="<%=(int) p.getPrice()%>" min="0" step="0.01" required
								placeholder="Enter price">
						</div>
					</div>
				</div>

				<div class="d-flex flex-wrap gap-2 mt-4 button-group">
					<button type="submit" class="btn-primary-custom">
						<i class="fa-solid fa-floppy-disk"></i> Update Product
					</button>

					<a href="ProductController?view=products"
						class="btn-secondary-custom"> <i class="fa-solid fa-xmark"></i>
						Cancel
					</a>
				</div>
			</form>
		</div>
	</div>

	<script>
// Add form validation and focus effects
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    const inputs = document.querySelectorAll('.form-control');
    
    // Add focus effects to inputs
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
    
    // Auto-focus on first input
    if (inputs.length > 0) {
        inputs[0].focus();
    }
    
    // Form validation
    form.addEventListener('submit', function(e) {
        let isValid = true;
        const quantityInput = document.querySelector('input[name="quantity"]');
        const priceInput = document.querySelector('input[name="price"]');
        
        // Validate quantity
        if (quantityInput.value < 0) {
            alert('Quantity cannot be negative');
            quantityInput.focus();
            isValid = false;
        }
        
        // Validate price
        if (priceInput.value < 0) {
            alert('Price cannot be negative');
            priceInput.focus();
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