package Operation;

import java.util.List;
import model.ProductPojo;

public interface ProductOperations {

	boolean addProduct(ProductPojo p);

	boolean updateProduct(ProductPojo p);

	boolean deleteProduct(int productId);

	ProductPojo getProductById(int productId);

	List<ProductPojo> getProductsBySeller(String sellerId);
}
