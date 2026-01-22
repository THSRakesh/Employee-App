using { StaffService, ProjectsService, AdminService } from './services';

annotate StaffService.Staff with @(
  Capabilities.Updatable:true,
  Capabilities.Deletable:true,

  UI.LineItem: [
    { Value:ID,            Label: 'ID' },
    { Value: EmpCode,      Label: 'Employee Code' },
    { Value: Name,         Label: 'Name' },
    { Value: Email,        Label: 'Email' },
    { Value: Mobile,       Label:'Mobile' },
    { Value: Status,       Label: 'Status' },
    { Value: organization.name, Label: 'Department' }
  ],

  UI.Identification: [
    {Value: ID, Label: 'ID'},
    {Value: Name, Label: 'Employee Name'},
    {Value: Email, Label: 'Email'},
    {Value: Mobile, Label: 'Mobile'},
    {Value: Salary, Label: 'Salary'},
    {Value: currency_code},
    {Value: organization.name, Label: 'Department'},
    {Value: shifts.shiftName, Label: 'Shifts'},
    {Value: currentTasks, Label: 'current Tasks'}
  ],

  UI.FieldGroup#DepartmentDetails:{
    Label:'Department Details',
    Data:[
      {Value: organization.ID, Label: 'Department ID'}, 
      {Value: organization.name, Label:'Department Name'}, 
      {Value: organization.parent.name, Label: 'Assigned To'}
    ]
  },

  UI.FieldGroup#ShiftsDetails:{
    Label:'Shifts Details',
    Data:[
      {Value: shifts.ID, Label:'Shifts ID'},
      {Value: shifts.shiftName, Label:'Shifts Name'}
    ]
  },

  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      Label : 'Staff Details',
      Target: '@UI.Identification'
    },
    {
      $Type: 'UI.ReferenceFacet', 
      Label:'Department Details', 
      Target:'@UI.FieldGroup#DepartmentDetails'
    },
    {
      $Type:'UI.ReferenceFacet',
      Label:'Working Shifts',
      Target:'@UI.FieldGroup#ShiftsDetails'
    }
  ],

  UI.HeaderInfo: {
    TypeName: 'Staff',
    TypeNamePlural: 'Staff',
    Title: { Value: Name },
    Description: { Value: EmpCode }
  }

);

annotate StaffService.Shifts with @(

  UI.LineItem: [
    { Value: shiftName, Label: 'Shift Name' }
  ],

  UI.HeaderInfo: {
    TypeName: 'Shift',
    TypeNamePlural: 'Shifts',
    Title: { Value: shiftName }
  }

);

annotate ProjectsService.Projects with @(

  UI.LineItem: [
    { Value: ID,       Label: 'Project ID' },
    { Value: total,    Label: 'Total Amount' },
    { Value: currency_code, Label: 'Currency' }
  ],

  UI.HeaderInfo: {
    TypeName: 'Project',
    TypeNamePlural: 'Projects',
    Title: { Value: ID }
  }

);

annotate ProjectsService.ProjectTasks with @(

  UI.LineItem: [
    { Value: staff_Id,  Label: 'Staff ID' },
    { Value: amount,    Label: 'Amount' },
    { Value: netAmount, Label: 'Net Amount' }
  ],

  UI.HeaderInfo: {
    TypeName: 'Task',
    TypeNamePlural: 'Tasks',
    Title: { Value: staff_Id }
  }

);

annotate AdminService.Shifts with @(

  UI.LineItem: [
    { Value: shiftName, Label: 'Shift Name' }
  ]

);
