###

Exposed events:
 - actionButtonClicked
$(".name-candidate-action-button").on("actionButtonClicked", (event, nameCandidate, nameCandidateGroup)->


Sample Template:
<div>                                                   Name Candiate Group
    <p>喜欢的名字</p>                       Name Candiate Group Header
        <div>                                               Name Candiate
            <span>名字#1</span>                Name Candiate Text
            <button>喜欢</button>             Name Candiate Action Button
            <button>排除</button>
            <button>待定</button>
        </div>
        <div>
            <span>名字#2</span>
            <button>喜欢</button>
            <button>排除</button>
            <button>待定</button>
        </div>
</div>      


Sample Template after rendered:
<div class="name-candidate-group">
    <p class="name-candidate-group-header">喜欢的名字</p>
        <div class="name-candidate">
            <span class="name-candidate-text">名字#1</span>
            <button class="name-candidate-action-button">喜欢</button>
            <button class="name-candidate-action-button">排除</button>
            <button class="name-candidate-action-button">待定</button>
        </div>
        <div class="name-candidate">
            <span class="name-candidate-text">名字#2</span>
            <button class="name-candidate-action-button">喜欢</button>
            <button class="name-candidate-action-button">排除</button>
            <button class="name-candidate-action-button">待定</button>
        </div>
</div>      
###

# Encapsulate the NameCandidate DOM object exposed the following props and methods:
#   .nameCandidate: jQuery object
#   .group: NameCandidateGroup instance
#
class NameCandidate

    # @nameCandidate: reference to the DOM object
    constructor: (@nameCandidate)->
        @nameCandidate = $(@nameCandidate)
    
    # Return the jQuery Object
    jQueryObj: ()->@nameCandidate

    moveToGroup: (anotherGroup, cb)->
        if !$.contains(anotherGroup.group.get(0), @jQueryObj().get(0))
            @jQueryObj().fadeOut('fast', ()=>
                anotherGroup.addNameCandidate(@);
                @jQueryObj().fadeIn('slow', cb);
            )

    removeFromGroup: (cb)->
        @jQueryObj().fadeOut('slow', ()->
            $(this).remove()
            cb()
        )
        

class NameCandidateGroup
    constructor: (@group, opt)->
        @group = $(@group)
        @options =
            groupClass: "name-candidate-group"
            groupHeaderClass: "name-candidate-group-header"
            nameCandidateClass: "name-candidate"
            nameCandidateText: "name-candidate-text"
            nameCandidateActionButton: 'name-candidate-action-button'
        $.extend(@options, opt ? {})

        # Init child controls
        @groupHeader = @group.find(">p")


    # Return the jQueryObj Object
    jQueryObj: ()->@group

    __nameCandidates: ()-> @group.find(">div")

    # Add CSS styles and maybe add more UI elements
    render: ()->
        @group.addClass(@options.groupClass)
        @groupHeader.addClass(@options.groupHeaderClass)
        @__nameCandidates()
            .addClass(@options.nameCandidateClass)
            .find(">span").addClass(@options.nameCandidateText).end()
            .find(">button").addClass(@options.nameCandidateActionButton).button().end()
        return @

    # Triggered when action buttons are clicked
    actionButtonClick: (handler)->
        @__nameCandidates().find("button.#{@options.nameCandidateActionButton}").click((event)->
            nameCandidate = new NameCandidate($(this).parent())
            handler.apply(this, _.toArray(arguments).concat([nameCandidate]))
        )
        return @
        

    addNameCandidate: (nameCandidate)->
        if !$.contains(@group.get(0), nameCandidate.jQueryObj().get(0))
            @group.append(nameCandidate.jQueryObj())

this.NameCandidateGroup = NameCandidateGroup