js = require "js"
import new, null from js
w = window or js.global
import document, localStorage, Array from w
{search:querystr} = w.location
import insert from table
import floor from math


-------- Fonctions auxiliaires pour interagir avec JS --------

_query_params_iter = w\decodeURIComponent(querystr\sub(2))\gmatch('[^&]+')
_query_params = {}
query_param = (cle) ->
  return _query_params[cle] if _query_params[cle]
  for k, v in ->
      i = _query_params_iter!
      i\match '([^=]+)=?(.*)' if i
    _query_params[k] = v if v else insert _query_params, k
    return v if k == cle
  return _query_params

fromArray = =>
  if js.instanceof @, Array
    [fromArray(e) for e in *@[0, -1]]
  else
    r = tonumber @
    if r
      @ = floor r
      @ = r if r == @
    @

toArray = =>
  _t = new Array
  dec = not @[0]
  for k, v in pairs @
    if dec and tonumber k then k -= 1
    _t[k] = type(v) == 'table' and toArray(v) or v
  _t

toJS = =>
  switch type @
    when 'string' js.tostring @
    when 'table' toArray @
    else @


launch = (t, fn=t) -> w\setTimeout fn, tonumber(t) or 0


chrono = (tache, fn) -> ->
  _t = os.clock!
  fn!
  print tache, os.clock! - _t


ls_getItem = (k, v) ->
  _v = localStorage\getItem(k)
  _v ~= null and _v or v


ls_setItem = localStorage\setItem


-------- Classe utile pour définir les divers objets --------

_els = {}

local EL
EL = {
  -- Objet représentant un élément de la page web
  __call: (id) =>
    _els[id] or= setmetatable {element: document\getElementById id}, EL
    _els[id]

  __index: (k) => rawget(EL, k) or @element[k]

  __newindex: (k, v) => @element[k] = v

  insert: (h, place) =>
    @element\insertAdjacentHTML (place or "beforeEnd"), tostring h
    @

  replace: (h) =>
    @element.innerHTML = tostring h
    @

  on: (event, fn) => @element\addEventListener event, fn

  hide: =>
    @element.style.display = 'none'
    @

  show: (mode = "block") =>
    @element.style.display = mode
    @

  is_hidden: => @element.style.display == 'none'

  __band: (el) => @insert el

  __lt: (h) => @replace h

  __shl: (h) => @insert h

  __tostring: => @element.outerHTML
}
setmetatable EL, EL

{
  :EL
  :chrono
  :launch
  :ls_getItem
  :ls_setItem
  :query_param
  :toArray
  :fromArray
  :toJS
}