import concat, insert from table
js = require "js"
global: w, global: {document: doc} = js
import new from js
import Array from w
gbId = doc\getElementById

----------------------- DOM -----------------------------------

_G = _G
H = {}
setfenv or= (env) =>
  i = 1
  while true
    name = debug.getupvalue(self, i)
    if name == "_ENV" then
      debug.upvaluejoin self, i, (-> env), 1
      break
    elseif not name
      break
    i = i + 1
  self

_html = (i) ->
  switch type i
    when 'table' tostring i if i.ishtml else concat[_html v for v in *i]
    when 'function' _html i!
    else tostring i

do
  attrs = (t) ->
    a = concat ["#{attr}#{val == true and '' or '=' .. val}" for attr, val in pairs t], ' '
    ' '..a if a != '' else ''
  H.__index = (k) =>
    return _G[k] if _G[k] and k != "table"
    k = 'table' if k == 'htable'
    r = {ishtml: true}
    r.__tostring = =>
      "<#{k}>"
    r.__call = (s) =>
      if type(s) == "table"
        ss = {}
        for i, v in ipairs s
          insert ss, _html v
          s[i] = nil
        ss = concat ss
        rr = {ishtml: true}
        rr.__tostring = =>
          if ss
            "<#{k}#{attrs(s)}>#{ss}</#{k}>"
          else
            "<#{k}#{attrs(s)}>"
        rr.__call = (sss) =>
          "<#{k}#{attrs(s)}>#{sss}</#{k}>"
        setmetatable rr, rr
        rr
      else
        "<#{k}>#{s}</#{k}>" if tostring s
    setmetatable r, r
    H[k] = r
    H[k]
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
    when 'string'
      js.tostring o
    when 'table'
      toArray o
    else o

lancer = (f, t = 0) -> w\setTimeout f, t * 1000


export dom = {
  html: => _html setfenv(self, H)!
  :EL
  :toJS
  :lancer
}