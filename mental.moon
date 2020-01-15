import time from os

--------------------- Calcul des énoncés --------------------

local m
do
  import floor, log, random, randomseed from require "math"

  MIN = 100
  randomseed(time!)

  bornes = (args) ->
    min = tonumber(args.Min or MIN) - 1
    max = tonumber(args.Max or 10 * min)
    min, max = max, min if min > max
    min, max, max - min

  pow = (a, n) ->
    r = 1
    r = r*a for i = 1, n
    r

  round = (d) ->
    f = floor d
    f if d - f < .5 else f + 1

  m = {}

  m.addition = {
    args: {
      Min: 10
      Max: 100
      ["Nbre de termes"]: 2
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      a = min + random delta
      b = min + random delta
      "#{a} + #{b} = ?", "#{a + b}"
  }

  m.complement = {
    args: {
      Min: 10
      Max: 100
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      a = min + random delta
      "#{a} + ? \n= #{max}", "#{max - a}"
  }

  m.multiplication = {
    args: {
      Min: 10
      Max: 100
      ["Nbre de termes"]: 2
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      a = min + random delta
      b = min + random delta
      "#{a} × #{b} \n= ?", "#{a * b}"
  }

  m.multiplication_ir = {
    args: {
      Min: 10
      Max: 100
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      c = min + 1 + 10 * random floor delta/10
      d = random min
      a = c + d
      b = c - d
      "#{a} × #{b} \n= ?", "#{a * b}"
  }

  m.multiplication_dc = {
    args: {
      Min: 10
      Max: 100
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      c = min + 1 + 10 * random floor delta/10
      d = random min
      a = c - min - 1 + d
      b = c - d
      "#{a} × #{b} \n= ?", "#{a * b}"
  }

  m["Ordre de grandeur"] = {
    args: {
      Min: 10
      Max: 100
      ["Nbre de termes"]: 2
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      a = min + random delta
      b = min + random delta
      oa = pow 10, floor log(a, 10)
      ob = pow 10, floor log(b, 10)
      ga = oa * round a/oa
      gb = ob * round b/ob
      "#{a} × #{b} \n≈ ?", "#{ga} × #{gb} = #{ga * gb}"
  }

  m.soustraction = {
    args: {
      Min: 10
      Max: 100
      ["Nbre de termes"]: 2
    }
    duree: 8
    (args) ->
      min, max, delta = bornes args
      a = min + random delta
      b = min + random delta
      "#{a} - #{b} \n= ?", "#{a - b}"
  }


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
    concat([(html -> {option {value: "'#{str}'", str}}) for str in pairs m], '')
  }
  span {id: "args"}
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

args = EL "args"
bouton = EL "lancer"
enonce = EL "enonce"
reponse = EL "reponse"
exercice = EL "exercice"

local nombre, duree
maj_args = -> --[[]]
  ex = m[exercice\value!]
  args < html -> {
    label "&nbsp Nbre"
    input {id: "nombre", value: 5}
    label "&nbsp Durée"
    input {id: "duree", value: ex.duree}
  }
  for k, v in pairs ex.args
    args << html -> {
      label "&nbsp #{k}"
      input {id: "'#{k}'", value: v}
    }
    val = EL(k)
    val.element.onchange = ->
      ex.args[id] = val\value!
  nombre = EL("nombre")\value
  duree = EL("duree")\value
  --]]

maj_args!

exercice.element.onchange = maj_args

bouton.element.onclick = ->
  reponse < ""
  ex = m[exercice\value!]
  d, n = tonumber(duree!), tonumber(nombre!)
  reponses = {}
  for i = 0, n - 1
    q, r = ex[1] ex.args
    insert reponses, {q, r}
    w\setTimeout (-> enonce < q\gsub '\n', '<br>'), 1000 * i * d
  w\setTimeout (-> enonce < "Terminé !"), 1000 * n * d
  w\setTimeout (->
    enonce < ""
    reponse < concat [r[1]\gsub("?", html -> {span{r[2], class:"resultat"}}) for r in *reponses], "<br>"
  ), 1000 * (n + 1) * d
