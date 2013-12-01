this.admin_index = class admin_index
        
        constructor: ()->
        
        run: ()->
            $("#accordion").accordion({ collapsible: true })
            $("button").button();
            $("#dialog-succ, #dialog-fail").dialog(
                autoOpen: false, modal: true, closeOnEscape: true,
                show: { effect: "blind", duration: 500 },
                hide: { effect: "explode", duration: 1500 }
            )

            $("#btn-clearDB").click(()=>
                $.post('/admin/clearDB')
                  .done((data)=>@__showSucc())
                  .fail((data)=>@__showFail())
            );

            $("#btn-autoGenNames").click(()=>
                $.post('/admin/autoGenNames', {
                    secondWordString: $("#secondWordString").val(),
                    thirdWordString: $("#thirdWordString").val()
                })
                  .done((data)=>@__showSucc())
                  .fail((data)=>@__showFail())
            )

            $("#btn-batchAddNames").click(()=>
                $.post('/admin/batchAddNames', {names: $("#batch-names").val()})
                  .done((data)=>@__showSucc())
                  .fail((data)=>@__showFail())
            )

            $("#btn-previewNamesTobeDel").click(()=>
                $.post('/admin/queryFilteredNames', {filters: $("#name-deletion-filters").val()})
                  .done((data)=>@__listNames(data))
                  .fail((data)=>
                    @__clearNames()
                    @__showFail()
                  )
            )

            $("#btn-delPreviewedNames").click(()=>
                $.post('/admin/delPreviewedNames', {filters: $("#name-deletion-filters").val()})
                  .done((data)=>@__showSucc())
                  .fail((data)=>@__showFail())
            )
        
        __showSucc: ()-> $("#dialog-succ").dialog("open")
        __showFail: ()-> $("#dialog-fail").dialog("open")
        __clearNames: ()-> $("#filtered-name-list").children().remove()
        __listNames: (names)->
            nameList = $("#filtered-name-list");
            @__clearNames();
            for nameCandidate in names
                nameCandidateElement = $("<div>").attr("data-id", nameCandidate._id).appendTo(nameList)
                $("<span>").text(nameCandidate.name).appendTo(nameCandidateElement);
                $("<button>").addClass("name-candidate-pending").text("删除").appendTo(nameCandidateElement);

            new window.NameCandidateGroup(nameList).render().actionButtonClick((event, nameCandidate)=>
                    id = nameCandidate.jQueryObj().data("id")
                    $.post('/admin/delAName', {id: id})
                        .done((data)=>nameCandidate.removeFromGroup(()=> @__showSucc()))
                        .fail((data)=>@__showFail())
            )