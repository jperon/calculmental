import concat from table

setfenv or= (env) =>
  i = 1
  while true
    if name = debug.getupvalue @, i
      if name == "_ENV"
        debug.upvaluejoin @, i, (-> env), 1
        break
    else break
    i += 1
  @

local H

html = =>
  switch type @
    when "table" concat[html(v) for v in *@]
    when "function"
      env = setmetatable {}, H
      setfenv(@, env)!
      concat [tostring(i) for i in *env]
    else tostring @

mt = {
  __tostring: =>
    k = @k
    k = k\sub(2) if k\sub(1, 1) == "_"
    content = concat [tostring(i) for i in *@]
    if k == "text" then content
    else
      attrs = @attrs and (
        concat [type(_v) == "boolean" and (_v and " #{_k}" or "") or " #{_k}=\"#{_v}\"" for _k, _v in pairs @attrs]
      ) or ''
      if #@ == 0 then "<#{k}#{attrs}/>"
      else "<#{k}#{attrs}>#{content}</#{k}>"
  __call: (...) =>
    for i = 1, select "#", ...
      item = select i, ...
      if type(item) == "table"
        @attrs = item
      else
        @[#@+1] = html item
}

H = __index: (k) =>
  return _G[k] if _G[k] and k ~= "table"
  k = "table" if k == "htable"
  v = setmetatable {:k}, mt
  @[#@+1] = v
  v
setmetatable H, H

:html
