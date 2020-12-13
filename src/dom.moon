import concat, insert from table
js = require "js"
global: w, global: {document: doc} = js
import new from js
import Array from w
gbId = doc\getElementById

----------------------- DOM -----------------------------------

setfenv or= (env) =>
  i = 1
  while true
    name = debug.getupvalue(@, i)
    if name == "_ENV" then
      debug.upvaluejoin @, i, (-> env), 1
      break
    elseif not name
      break
    i = i + 1
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

H = __index: (k) =>
  return _G[k] if _G[k] and k ~= "table"
  k = "table" if k == "htable"
  k = k\sub(2) if k\sub(1, 1) == "_"
  v = {attrs: {}}
  v.__tostring = =>
    attrs = next(@attrs) and (
      concat [type(_v) == "boolean" and (_v and " #{_k}" or "") or " #{_k}=\"#{_v}\"" for _k, _v in pairs @attrs]
    ) or ""
    content = concat [tostring(i) for i in *@]
    if k == "text" then content
    elseif #@ == 0 then "<#{k}#{attrs}>"
    else "<#{k}#{attrs}>#{content}</#{k}>"
  v.__call = (...) =>
    _args = {...}
    for i in *_args
      if type(i) == "table"
        @attrs[_k] = _v for _k, _v in pairs i
      else
        @[#@+1] = html i
  setmetatable v, v
  @[#@+1] = v
  v
setmetatable H, H


class EL
  -- Objet représentant un élément de la page web
  new: (id, tp) =>
    @el = gbId id
    unless @el
      @el = doc\createElement tp
      @el.setAttribute 'id', id

  append: (h, place) =>
    @el\insertAdjacentHTML place or "beforeEnd", h
    self

  replace: (h) =>
    @el.innerHTML = h
    self

  value: =>
    self.el.value

  __lt: (h) => @replace h

  __shl: (el) => @append el


toArray = (t) ->
  _t = new Array
  dec = not t[0]
  for k, v in pairs t
    if dec and tonumber k then k -= 1
    _t[k] = type(v) == 'table' and toArray(v) or v
  _t

toJS = (o) ->
  switch type o
    when 'string' js.tostring o
    when 'table' toArray o
    else o

lancer = (f, t = 0) -> w\setTimeout f, t * 1000


export dom = {
  :html
  :EL
  :toJS
  :lancer
}