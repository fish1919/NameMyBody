_ = require('underscore')
async = require('async')
util = require('util')
DbDal = require('../dal/DbDal')

NameCandidate = DbDal.NameCandidate
NameSrc = DbDal.NameSrc

module.exports = class NameRoute
    constructor: (@app)->

    addRequestHandlers: ()->
        @app.get('/', _.bind(@handleIndex, @))
        @app.get('/voter/login', _.bind(@handleVotorLogin, @))
        @app.get('/:voter/vote', _.bind(@handleVoterVote, @))
        @app.get('/:voter/voteFor', _.bind(@handleVoterVoteFor, @))

    handleIndex: (req, res)-> res.redirect(301, "/voter/login")
    
    
    handleVotorLogin: (req, res)->
        voters = [
            {displayName: '熊猫'}
            {displayName: '云'}
            {displayName: '一苇渡江'}
        ]
        res.render('page_voter_login', {voters: voters})


    handleVoterVote: (req, res)->
        voter = req.params.voter
        @__getCandidateNamesFromDb(voter, (err, results)->
            res.render('page_voter_vote.ejs', {voter: voter, nameCandidates: results})
        )       


    handleVoterVoteFor: (req, res)->
        voter = req.params.voter
        {id, score} = req.query

        queryClouse = {_id: id}
        updateClouse = {}
        updateClouse["votes.#{voter}"] = parseInt(score, 10)
        NameCandidate.findOneAndUpdate(queryClouse, updateClouse,  (err, numberAffected)=>
            if err then res.send(500, err)
            else
                console.log(numberAffected)
                res.json(200, numberAffected)
        )


    __getCandidateNamesFromDb: (voter, cb)->
        NameCandidate.find(null, null, {sort: {name: 1}}, (err, docs)->
            results = 
                preferred: []
                disliked: []
                pending: []
                unvoted: []

            for name in docs
                score = name.votes?[voter]
                simpleName = _.pick(name, '_id', 'name')
                if (score is undefined)
                    results.unvoted.push(simpleName)
                else
                    if score > 0 then results.preferred.push(simpleName)
                    else if score < 0 then results.disliked.push(simpleName)
                    else results.pending.push(simpleName) # score is 0

            cb(null, results)
        )
