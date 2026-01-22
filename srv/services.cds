using {training.db.App as db} from '../db/schema';

// Define Book Service
service StaffService{
    @odata.draft.enabled
    entity Staff as projection on db.Staff {*, department as organization} excluding{department, createdAt, createdBy, modifiedAt, modifiedBy};
    entity Shifts as projection on db.Shifts;
}

// Define Projects Service
service ProjectsService{
    // @(restrict:[
    //     { grant: '*', to: 'Administrators' },
    //     { grant: '*', where: 'createdBy=$user' }
    // ])
    entity Projects as projection on db.Projects;
    // @(restrict:[
    //     {grant:'*', to:'Administrators'},
    //     {grant:'*', where:'parent.createdBy=$user'}
    // ])
    entity ProjectTasks as projection on db.ProjectTasks;
}

// Define Admin Service
using {AdminService} from '@rakesh/training-employees';
extend service AdminService with{
    entity Shifts as projection on db.Shifts;
}

