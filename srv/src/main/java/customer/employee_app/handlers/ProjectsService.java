package customer.employee_app.handlers;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.sap.cds.ql.Select;
import com.sap.cds.ql.Update;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.ql.cqn.CqnUpdate;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;
import com.sap.cds.services.cds.CqnService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.After;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import cds.gen.adminservice.Staff;
import cds.gen.projectsservice.ProjectTasks;
import cds.gen.projectsservice.ProjectTasks_;
import cds.gen.projectsservice.Projects;
import cds.gen.projectsservice.ProjectsService_;
import cds.gen.projectsservice.Projects_;
import cds.gen.staffservice.Staff_;

@Component
@ServiceName(ProjectsService_.CDS_NAME) // it is same as ProjectsService safer,cleaner bcoz it is generated from CDS
public class ProjectsService implements EventHandler{
    @Autowired
    PersistenceService db; // CAP java database service object It is used to talk to DB layer
    
    @Before(event = CqnService.EVENT_CREATE, entity = ProjectTasks_.CDS_NAME)
    public void validateEmpAndAddTasks(List<ProjectTasks> tasks){
        for(ProjectTasks task:tasks){
            String staffId=task.getStaffId();
            Integer amount=task.getAmount();
            
            CqnSelect query=Select.from(Staff_.class).columns("Status", "currentTasks").where(b->b.ID().eq(staffId));
            Staff st=db.run(query).first(Staff.class)
                        .orElseThrow(()-> new ServiceException(ErrorStatuses.NOT_FOUND, "Employee not Found"));

                        /*
                         * CqnSelect it holds the select statement
                         * columns contains which columns to show
                         * where contains where condition
                         * here it is like select Status,currentTasks from Staff where id=staffId
                         * db.run is used to run the query
                         * first means takes the first row and maps it into a staff
                         * if first is in empty means no record then throw an exception
                         */
            
            String Status=st.getStatus();
            if(Status.equalsIgnoreCase("InActive")){
                throw new ServiceException(ErrorStatuses.BAD_REQUEST, "Employee is InActive");
            }
            //here is employee status is inActive then show me error with given message

            int currentTasks=st.getCurrentTasks()==null? 0: st.getCurrentTasks();
            amount=task.getAmount()==null? 0: task.getAmount();
            st.setCurrentTasks(currentTasks+amount); // here we are adding the new task to current tasks
            CqnUpdate update=Update.entity(Staff_.class).data(st).where(b->b.ID().eq(staffId)); //it is update statement
            db.run(update); // to run a query
        }
    }

    @Before(event = CqnService.EVENT_CREATE, entity = Projects_.CDS_NAME)
    public void validateEmpAndCreateTasks(List<Projects>projects){
        for(Projects project:projects){
            if(project.getTasks()!= null){
                validateEmpAndAddTasks(project.getTasks());
            }
        }
    }

    @After(event = {CqnService.EVENT_READ, CqnService.EVENT_CREATE}, entity = ProjectTasks_.CDS_NAME)
    public void calculateNetAmount(List<ProjectTasks>tasks){
        for(ProjectTasks task:tasks){
            String staffId=task.getStaffId();

            CqnSelect query=Select.from(Staff_.class).where(b->b.ID().eq(staffId));
            Staff st=db.run(query).first(Staff.class)
                    .orElseThrow(()-> new ServiceException(ErrorStatuses.NOT_FOUND, "Project Tasks not Found"));;

            //  We need to calculate net amount in two events
             
            /* if user call the get API 
             * Read event triggers, CAP fetches data from db
             * @after Read executes, Result sent to UI
             */

            /* Single expects only a single row to be returned
            if it return 0 or more than 1 it returns error */  
            
            task.setNetAmount(st.getSalary().multiply(new BigDecimal(task.getAmount())));
        }
    }

    @After(event = {CqnService.EVENT_CREATE, CqnService.EVENT_READ}, entity = Projects_.CDS_NAME)
    public void calculateTotal(List<Projects>projects){
        for(Projects project:projects){
            if(project.getTasks()!=null){
                calculateNetAmount(project.getTasks());
            }

            CqnSelect query=Select.from(ProjectTasks_.class).where(i-> i.parent().ID().eq(project.getId())); 
            // here parentId is foreign key so we dont write parent_id() so use parent().ID()
            // Universal CAP java rule all foreign keys are calls like this only department().code(), customer().ID()
            List<ProjectTasks>allTasks=db.run(query).listOf(ProjectTasks.class); // Map Each Row to Project Tasks Java Object
            calculateNetAmount(allTasks);

            BigDecimal total=new BigDecimal(0);
            for(ProjectTasks task:allTasks){
                total=total.add(task.getNetAmount());
            }
            project.setTotal(total);
        }
    }
}
