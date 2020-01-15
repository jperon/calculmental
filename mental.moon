import time from os

--------------------- Calcul des énoncés --------------------

local m
do
  import floor, random, randomseed from require "math"

  MIN = 100
  randomseed(time!)


  bornes = (min, max) ->
    min = tonumber(min or MIN) - 1
    max = tonumber(max or 10 * min)
    min, max = max, min if min > max
    min, max, max - min


  m = {}

  m.addition = (min, max) ->
    min, max, delta = bornes min, max
    a = min + random delta
    b = min + random delta
    "#{a} + #{b} \n= ?", "#{a + b}"

  m.complement = (min, max) ->
    min, max, delta = bornes min, max
    a = min + random delta
    "#{a} + ? \n= #{max}", "#{max - a}"

  m.multiplication = (min, max) ->
    min, max, delta = bornes min, max
    a = min + random delta
    b = min + random delta
    "#{a} × #{b} \n= ?", "#{a * b}"

  m.multiplication_ir = (min, max) ->
    min, max, delta = bornes min, max
    c = min + 1 + 10 * random floor delta/10
    d = random min
    a = c + d
    b = c - d
    "#{a} × #{b} \n= ?", "#{a * b}"

  m.multiplication_dc = (min, max) ->
    min, max, delta = bornes min, max
    c = min + 1 + 10 * random floor delta/10
    d = random min
    a = c - min - 1 + d
    b = c - d
    "#{a} × #{b} \n= ?", "#{a * b}"

  m.soustraction = (min, max) ->
    min, max, delta = bornes min, max
    a = min + random delta
    b = min + random delta
    "#{a} - #{b} \n= ?", "#{a - b}"


----------------------- DOM -----------------------------------

import concat, insert, remove from table
js = require "js"
global: w, global: {:document, :WebSocket} = js
gbId = document\getElementById


html = do
  _G = _G
  H = {}
  setfenv = setfenv or (fn, env) ->
    i = 1
    while true
      name = debug.getupvalue(fn, i)
      if name == "_ENV" then
        debug.upvaluejoin fn, i, (-> env), 1
        break
      elseif not name
        break
      i = i + 1
    fn
  getfenv = getfenv or (fn) ->
    i = 1
    while true
      name, val = debug.getupvalue(fn, i)
      if name == "_ENV"
        return val
      elseif not name then
        break
      i = i + 1
  html = (fn) ->
    fn = setfenv(fn, H)
    concat [tostring v for v in *fn!], ''

  do
    attrs = (t) ->
      a = concat ["#{attr}=#{val}" for attr, val in pairs t], ' '
      ' '..a if a != '' else ''
    H.__index = (_, k) ->
      return _G[k] if _G[k] and k != "table" and k != "select"
      k = 'table' if k == 'htable'
      r = {}
      r.__tostring = (_) ->
        "<#{k}>"
      r.__call = (_, s) ->
        switch type s
          when "table"
            ss = ''
            while s[1]
              ss = ss .. tostring remove s, 1
            rr = {}
            rr.__tostring = (str) ->
              if ss
                "<#{k}#{attrs(s)}>#{ss}</#{k}>"
              else
                "<#{k}#{attrs(s)}>"
            rr.__call = (_, ss) ->
              "<#{k}#{attrs(s)}>#{ss}</#{k}>"
            setmetatable rr, rr
            rr
          else
            "<#{k}>#{s}</#{k}>" if tostring s
      setmetatable r, r
      H[k] = r
      H[k]
    setmetatable H, H
  html


class EL
  -- Objet représentant un élément de la page web
  new: (id) =>
    @element = gbId id

  append: (h, place) =>
    @element\insertAdjacentHTML place or "beforeEnd", h
    self

  replace: (h) =>
    @element.innerHTML = h
    self

  value: =>
    self.element.value

  __lt: (h) => @replace h

  __shl: (el) => @append el


-------- Procédure --------

body = EL "corps"
body << html -> {
  h1 "Calcul mental"
  select {
    id: "exercice"
    name: "Exercice"
    concat([(html -> {option {value: str, str}}) for str in pairs m], '')
  }
  label "&nbsp Durée"
  input {id: "duree", value: 8}
  label "&nbsp Nombre"
  input {id: "nombre", value: 5}
  label "&nbsp Min"
  input {id: "min", value: 100}
  label "&nbsp Max"
  input {id: "max", value: 1000}
  "&nbsp"
  button {id: "lancer", "C'est parti !"}
  div {
    id: "question", class: "zone"
    p {id: "enonce"}
  }
  div {
    id: "reponse", class: "zone"
  }
}

bouton = EL "lancer"
enonce = EL "enonce"
reponse = EL "reponse"
exercice = EL("exercice")\value
duree = EL("duree")\value
nombre = EL("nombre")\value
min = EL("min")\value
max = EL("max")\value

bouton.element.onclick = ->
  reponse < ""
  d, n = tonumber(duree!), tonumber(nombre!)
  reponses = {}
  for i = 0, n - 1
    q, r = m[exercice!] min!, max!
    insert reponses, {q, r}
    w\setTimeout (-> enonce < q\gsub '\n', '<br>'), 1000 * i * d
  w\setTimeout (-> enonce < "Terminé !"), 1000 * n * d
  w\setTimeout (->
    enonce < ""
    reponse < concat [r[1]\gsub("?", html -> {span{r[2], class:"resultat"}}) for r in *reponses], "<br>"
  ), 1000 * (n + 1) * d
