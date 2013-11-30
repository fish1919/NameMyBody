_ = require('underscore')
should = require('should')
mongoose = require('mongoose');
Schema = mongoose.Schema;
# Mongoose Schemas
#

NameSrcSchema = new mongoose.Schema(
        secondWordList: [String],
        thirdWordList: [String]
)
NameSrcSchema.method("genNameCandidates", ()->
    nameCandidates = []
    for midWord in @secondWordList
        for thirdWord in @thirdWordList
            nameCandidates.push('冯' + midWord + thirdWord)
    return nameCandidates
)

NameCandidateSchema = new mongoose.Schema(
        name: String
        votes: Schema.Types.Mixed
)
NameCandidateSchema.method( "validateAndFormat", ()->
    # validate
    if (!@name or @name is '') then return false
    # format
    if (!@name[0] is "冯") then @name = "冯" + @name
    return true
)
NameCandidateSchema.static( "saveIfNotExists", (entity, cb)->
    should.exist(entity, "Parameter 'entity' cannot be null.")
    should.exist(entity.name, "Parameter 'entity.name' cannot be null.")
    
    conditions = _.pick(entity, "name");
    @findOne(conditions, (err, result)->
        if (err) then cb(err, result)
        else
            if( !result) then entity.save(cb)
            else cb(null, result)
    )
)

exports.NameSrc = mongoose.model('name_src', NameSrcSchema);
exports.NameCandidate = mongoose.model('name_candidate', NameCandidateSchema);
exports.MongoDB = class MongoDB
    connect: ()->
        if (process.env.VCAP_SERVICES)
            env = JSON.parse(process.env.VCAP_SERVICES);
            mongo = env['mongodb-1.8'][0]['credentials'];
        else
            mongo =
                "hostname":"localhost",
                "port":27017,
                "username":"",
                "password":"",
                "name":"",
                "db":"NameMyBaby"

        if (mongo.username && mongo.password)
            mongoUrl = "mongodb://#{mongo.username}:#{mongo.password}@#{mongo.hostname}:#{mongo.port}/#{mongo.db}"
        else
            mongoUrl = "mongodb://#{mongo.hostname}:#{mongo.port}/#{mongo.db}"

        mongoose.connect(mongoUrl)
