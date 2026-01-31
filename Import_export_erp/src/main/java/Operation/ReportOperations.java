package Operation;

import java.util.List;
import model.ReportPojo;

public interface ReportOperations {

    List<ReportPojo> viewReportsByUser(String portId);

    void updateReportStatus(int reportId);

    List<ReportPojo> viewReportsByProduct(int productId);
}
