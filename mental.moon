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

  m = {
    ["Addition"]:
      ["Somme"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          r = min + random delta
          q = "#{r}"
          print @args["Nbre de termes"]
          for i = 2, tonumber @args["Nbre de termes"]
            a = min + random delta
            q = "#{q} + #{a}"
            r = r + a
            print i, q, r
          "#{q} = ?", "#{r}"
      }
    ["Soustraction"]:
      ["Différence"]: {
        args: {
          Min: 10
          Max: 100
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          a = min + random delta
          b = min + random delta
          "#{a} - #{b} \n= ?", "#{a - b}"
      }
      ["Complément"]: {
        args: {
          Min: 10
          Ref: 100
        }
        duree: 8
        fn: =>
          @args.Max = @args.Ref
          min, max, delta = bornes @args
          a = min + random delta
          "#{a} + ? \n= #{max}", "#{max - a}"
      }
    ["Multiplication"]:
      ["Produit"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          a = min + random delta
          b = min + random delta
          "#{a} × #{b} \n= ?", "#{a * b}"
      }
      ["Ordre de grandeur"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          a = min + random delta
          b = min + random delta
          oa = pow 10, floor log(a, 10)
          ob = pow 10, floor log(b, 10)
          ga = oa * round a/oa
          gb = ob * round b/ob
          "#{a} × #{b} \n≈ ?", "#{ga} × #{gb} = #{ga * gb}"
      }
      ["Identités remarquables"]: {
        args: {
          Min: 10
          Max: 100
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          c = min + 1 + 10 * random floor delta/10
          d = random min
          a = c + d
          b = c - d
          "#{a} × #{b} \n= ?", "#{a * b}"
      }
      ["Multiplication astucieuse"]: {
        args: {
          Min: 10
          Max: 100
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          c = min + 1 + 10 * random floor delta/10
          d = random min
          a = c - min - 1 + d
          b = c - d
          "#{a} × #{b} \n= ?", "#{a * b}"
      }
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
      a = concat ["#{attr}='#{val}'" for attr, val in pairs t], ' '
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
  div {
    id: "exercices"
    div {
      id: "liste_exercices"
    }
    "&nbsp"
    button {id: "lancer", "C'est parti !"}
  }
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
liste_exercices = EL "liste_exercices"
exercices = EL "exercices"
reponse = EL "reponse"

for categorie, operation in pairs m
  id = "#{categorie}_table"
  liste_exercices << html -> {
    h2 {id: categorie, a {href:"#", categorie}}
    table {id: id, style:"display:none"}
  }
  liste_categorie = EL id
  for titre, exo in pairs operation
    liste_categorie << html -> {
      tr {
        id: "#{titre}_args"
        class: "args"
        td {label {class:"titre", titre}}
        td {
          label "&nbsp Nbre"
          input {id: "#{titre}_nombre", value: 0}
          label "&nbsp Durée"
          input {id: "#{titre}_duree", value: exo.duree}
        }
      }
    }
    for k, v in pairs exo.args
      EL("#{titre}_args") << html -> {
        td{label "&nbsp #{k}"}
        td{input {id: "#{titre}_#{k}", value: v}}
      }
  titre_categorie = EL categorie
  titre_categorie.element.onclick = ->
    print liste_categorie.element.style.visibility
    if liste_categorie.element.style.display == "none"
      liste_categorie.element.style.display = "block"
    else
      liste_categorie.element.style.display = "none"


bouton.element.onclick = ->
  enonce < "Prêt ?"
  exercices.element.style.visibility = "hidden"
  reponse < ""
  serie = {}
  t = 3
  for _, categorie in pairs m
    for titre, exo in pairs categorie
      duree = tonumber EL("#{titre}_duree")\value!
      for arg in pairs exo.args
        exo.args[arg] = EL("#{titre}_#{arg}")\value!
      for n = 1, tonumber EL("#{titre}_nombre")\value!
        insert serie, {
          temps: t * 1000
          fn: exo\fn
        }
        t = t + duree
  reponses = {}
  for {:temps, :fn} in *serie
    q, r = fn!
    insert reponses, {q, r}
    w\setTimeout (-> enonce < q\gsub '\n', '<br>'), temps
  w\setTimeout (-> enonce < "Terminé !"), 1000 * t
  w\setTimeout (->
    enonce < ""
    reponse < concat [r[1]\gsub("?", html -> {span{r[2], class:"resultat"}}) for r in *reponses], "<br>"
  ), 1000 * (t + 3)
