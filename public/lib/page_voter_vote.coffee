this.voter_vote = class voter_vote

    constructor: (nameCandidateGroupsContainer)->
        nameCandidateGroupsContainer = $(nameCandidateGroupsContainer)
        @nameCandidateGroups = for divButtonGroupContainer in nameCandidateGroupsContainer.find(">div")
            buttonGroup = new window.NameCandidateGroup(divButtonGroupContainer)

   
    run: ()->
        that = this
        for group in @nameCandidateGroups
            group.render()
            group.actionButtonClick((event, nameCandidate)->
                that.__handleActionButtonClicked(this, nameCandidate))


    __getCorrespondGroup: (actionButton)->
        actionButton = $(actionButton)
        #for group in @nameCandidateGroups when actionButton.hasClass(cssName)
        for group in @nameCandidateGroups 
            cssName = group.jQueryObj().data("action-button-class")
            if (actionButton.hasClass(cssName))
                return group


    __updateNameInDB: (nameCandidate, score, cb)->
        $nameCandidate = nameCandidate.jQueryObj()
        queryParams =
            id: $nameCandidate.data("id"),
            name: $nameCandidate.find(".name-candidate-text").text(),
            score: score
    
        jqxhr = $.get(nameCandidate.jQueryObj().parent(".name-candidate-group").data("url"), queryParams);
        jqxhr.done((data)->
            $nameCandidate.attr("data-id", data._id);
            cb(null, $nameCandidate);
        )
        jqxhr.fail(()->cb("Error"))


    __handleActionButtonClicked: (actionButton, nameCandidate)->
        targetGroup = @__getCorrespondGroup(actionButton)
        score = targetGroup.jQueryObj().data("score")
        @__updateNameInDB(nameCandidate, score, (err)=>
            if (err) then alert('不明原因的错误');
            else nameCandidate.moveToGroup(targetGroup)
        )


