plv8 = require('../../plpl/src/plv8')
crud = require('../../src/core/crud')
schema = require('../../src/core/schema')
search = require('../../src/core/search')

# describe "CORE: search scratch", ()->
#   beforeEach ()->
#     schema.create_storage(plv8, 'Patient')

#   it "something", ()->

#     console.log search.search_sql(plv8,
#       resourceType: 'Patient'
#       query: ['or',
#         [['name',0,'given',0], '=', 'Ivan']
#         [['name','#','given','#'], '=', 'Ivan']
#       ]
#       count: 10
#     )
