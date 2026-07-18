({
    doInit: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        var parentId = myPageRef.state.c__parentId;
        var documentName = myPageRef.state.c__documentName;
        cmp.set("v.recordId", recordId);
        cmp.set("v.parentId" ,parentId);
        cmp.set("v.documentName" ,documentName);
        console.log('testing');
        // console.log('!!!!' , recordId);
        // console.log('!!!!' , applicantId);
        // cmp.set("v.showModal",true);
    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})