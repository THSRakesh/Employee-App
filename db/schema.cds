namespace training.db.App;

using{Currency, cuid, managed} from '@sap/cds/common';
using{training.db.Employees as emp} from '@rakesh/training-employees';

entity Staff as projection on emp.Employees;extend emp.Employees with{
    shifts:Association to Shifts;
}

entity Shifts{
    key ID: String(10);
        shiftName : String(111);
        staff:Composition of many Staff on staff.shifts=$self;
}

@Capabillities.Updatable:false
entity Projects :cuid, managed{
    tasks:Composition of many ProjectTasks on tasks.parent=$self;
    total:Decimal(9,2) @readonly;
    currency:Currency;
}

@Capabilities.Updatable:false
entity ProjectTasks:cuid{
    @mandatory
    parent:Association to Projects not null;
    staff_Id:UUID;
    amount:Integer;
    netAmount:Decimal(9,2) @readonly;
}