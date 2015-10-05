sql = require('../honey')

isArray = (v)-> Array.isArray(v)
isFn = (v)-> typeof v == "function"
isObject = (v)->  !!v && not isArray(v) && v.constructor == Object

merge = (into, args)->
  (args || []).reduce(((acc, x)->
    for k,v of x
      if acc[k]
        acc[k].push(v)
      else
        acc[k] = v
    acc
  ), into)

key_merge = (key, init, args)->
  for a in args when a[key]
    init.push(a[key])
  res = merge({}, args)
  res[key] = init
  res

table_name = (x)-> x.toLowerCase()

TABLE =
  search: (resourceType, args...)->
    merge({select: [':*'], from: [table_name(resourceType)]}, args)

  equal: (left, right)->
    where: [':=', left, right]

  contains: (left, right)->
    where: [':&&', left, right]

  param: (path...)->
    call: 'extract',
    args: [':resource', path]
    array: true

  and: (args...)->
    key_merge('where', [':and'], args)

  or: (args...)->
    key_merge('where', [':or'], args)

  ref: (field,res)->
    join: [[[res,res], [':=', "^ref(#{field})",':id']]]

  join: (args...)->
    merge({}, args)

  order: (args...)->
    order: args

  limit: (num)->
    limit: num

  offset: (num)->
    offset: num

_eval = (expr)->
  if isArray(expr)
    first = expr[0]
    if isFn(first)
      args = expr[1..].map(_eval)
      first.apply(null, args)
    else
      expr.map(_eval)
  else if isObject(expr)
    for k,v of expr
      expr[k] = _eval(v)
    expr
  else
    expr

x = TABLE

program = [x.search,
  'Patient'
  [x.order, ['name', 'desc'], ['birthDate', 'asc']]
  [x.limit, 10]
  [x.join, [x.ref, 'organization', 'Organization']]
  [x.and,
    [x.equal, [x.param, 'type'], 'animal']
    [x.or,
      [x.contains, [x.param, 'name', 'given'], 'ivan']
      [x.equal, [x.param, 'active'], 'true']]]
  [x.offset, 10]]

res = _eval(program)
console.log(res)
console.log(sql(res))