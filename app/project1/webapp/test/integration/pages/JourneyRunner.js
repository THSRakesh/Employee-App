sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"project1/test/integration/pages/StaffList",
	"project1/test/integration/pages/StaffObjectPage"
], function (JourneyRunner, StaffList, StaffObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('project1') + '/test/flpSandbox.html#project1-tile',
        pages: {
			onTheStaffList: StaffList,
			onTheStaffObjectPage: StaffObjectPage
        },
        async: true
    });

    return runner;
});

