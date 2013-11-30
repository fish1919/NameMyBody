_ = require('underscore')
async = require('async')
util = require('util')
should = require('should')
DbDal = require('../dal/DbDal')

NameCandidate = DbDal.NameCandidate
NameSrc = DbDal.NameSrc

module.exports = class AdminRoute
    constructor: (@app)->

    addRequestHandlers: ()->
        @app.get('/admin', _.bind(@handleIndex, @))
        @app.post('/admin/clearDB', _.bind(@handleAjaxClearDB, @))
        @app.post('/admin/autoGenNames', _.bind(@handleAjaxAutoGenNames, @))
        @app.post('/admin/batchAddNames', _.bind(@handleAjaxBatchAddNames, @))
        @app.post('/admin/queryFilteredNames', _.bind(@handleQueryFilteredNames, @))
        @app.post('/admin/delPreviewedNames', _.bind(@handleAjaxClearDB, @))
        #@app.get('/admin/sysInit', _.bind(@handleSysInit, @)

    handleIndex: (req, res)-> res.render("page_admin_index")


    handleAjaxClearDB: (req, res)->
        @__dropTables((err)-> if (err) then res.json(500) else res.json(200))
    

    handleAjaxAutoGenNames: (req, res)->
        {secondWordString, thirdWordString} = req.body
        should.exist(secondWordString, "Query parameter 'req.body.secondWordString' cannot be null")
        should.exist(thirdWordString, "Query parameter 'req.body.thirdWordString' cannot be null")

        @__generateCandidateNames(secondWordString, thirdWordString, (err)->
            if (err) then res.json(500)
            else res.json(200)
         )

    handleAjaxBatchAddNames: (req, res)->
        {names} = req.body
        should.exist(names, "Query parameter 'req.body.names' cannot be null")

        @__batchAddNames(names, (err)->
            if (err) then res.json(500)
            else res.json(200)
         )


     handleQueryFilteredNames: (req, res)->
        {filters} = req.body
        should.exist(filters, "Query parameter 'req.body.filters' cannot be null")

        # Empty filters return all the results
        if filters is '' then conditions = [true]
        else
            conditions = for filter in filters.split(",") when filter isnt ''
                {name: new RegExp("#{filter}")}
       
        NameCandidate.find({ "$or": conditions }, (err, entities)->
            if (err) then res.json(500)
            else res.json(200, entities)
        )

    __dropTables: (cb)->
        clearTableRoutins = [
            (cb)-> NameCandidate.remove({}, cb)
            (cb)-> NameSrc.remove({}, cb)
        ]
        async.parallel(clearTableRoutins, cb)
    
     
     __generateCandidateNames: (secondWordString, thirdWordString, cb) ->

        should.exist(secondWordString, "Parameter 'secondWordString' cannot be null")
        should.exist(thirdWordString, "Parameter 'thirdWordString' cannot be null")

        namesrc = new NameSrc()
        namesrc.secondWordList = secondWordString.split('')
        namesrc.thirdWordList =thirdWordString.split('')

        async.parallel([
            # 1. Add the namesrc to DB
            (cb)->namesrc.save(cb)
            # 2. Add generated name candidates to DB
            (cb)->
                candidates =  _.uniq(namesrc.genNameCandidates())
                iterator = (name, callback)->
                    nameCandidate = new NameCandidate()
                    nameCandidate.name = name
                    if (nameCandidate.validateAndFormat())
                        NameCandidate.saveIfNotExists(nameCandidate, callback)
                    else
                        callback(null)
                async.each(candidates, iterator, cb)
        ], cb)

     __batchAddNames: (names, cb) ->
        should.exist(names, "Parameter 'names' cannot be null")
        iterator = (name, callback)->
            nameCandidate = new NameCandidate()
            nameCandidate.name = name
            if (nameCandidate.validateAndFormat())
                NameCandidate.saveIfNotExists(nameCandidate, callback)
            else
                callback(null)

        async.each(names.split(","), iterator, cb)

            