import time from os
math = require "math"

--------------------- Calcul des énoncés --------------------

local m
do
  import abs, floor, log, random, randomseed from math

  MIN = 100
  randomseed(time!)

  bornes = (args) ->
    min = tonumber(args.Min or MIN) - 1
    max = tonumber(args.Max or 10 * min)
    min, max = max, min if min > max
    min, max, max - min, args.Relatifs

  pow = (a, n) ->
    return 1 if n == 0
    return a if n == 1
    pow a*a, n/2 if n % 2 == 0 else a * pow a*a, (n-1)/2

  round = (d) ->
    f = floor d
    f if d - f < .5 else f + 1

  tirer = (min, delta, relatifs, sansparentheses) ->
    r = (min + random delta) * (relatifs and (pow -1, random 2) or 1)
    r, (sansparentheses or r > 0) and "#{r}" or "(#{r})"

  m = {
    ["Addition"]:
      ["Somme"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
          Relatifs: false
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs = bornes @args
          r, q = tirer min, delta, relatifs, true
          for i = 2, tonumber @args["Nbre de termes"]
            a, s = tirer min, delta, relatifs
            q = "#{q} + #{s}"
            r = r + a
          "#{q}\n= ?", "#{r}"
      }
      ["Additions et soustractions"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
          Relatifs: false
        }
        duree: 8
        fn: =>
          n_termes = tonumber @args["Nbre de termes"]
          min, max, delta, relatifs = bornes @args
          r, q = tirer min, delta, relatifs, true
          for i = 2, n_termes
            min, delta = -r, (max + r > 1 and max + r or 2) if not relatifs and i == n_termes and r < 0 and -r > min
            a, s = tirer min, delta, relatifs
            soustraction = (relatifs or (r + a > -max and i < n_termes) or r - a > 0) and pow(-1, random 2) == -1
            q = q .. (soustraction and " - #{s}" or " + #{s}")
            r = r + (soustraction and -a or a)
          "#{q}\n= ?", "#{r}"
      }
    ["Soustraction"]:
      ["Différence"]: {
        args: {
          Min: 10
          Max: 100
          Relatifs: false
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs = bornes @args
          a, q = tirer min, delta, relatifs, true
          delta = a - min if not relatifs and max > a
          b, s = tirer min, delta, relatifs
          "#{q} - #{s}\n= ?", "#{a - b}"
      }
      ["Complément"]: {
        args: {
          Min: 10
          Ref: 100
        }
        duree: 8
        fn: =>
          min, max, delta = bornes {Min: @args.Min, Max: @args.Max}
          a = min + random delta
          "#{a} + ?\n= #{max}", "#{max - a}"
      }
    ["Multiplication"]:
      ["Produit"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
          Relatifs: false
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs = bornes @args
          r, q = tirer min, delta, relatifs, true
          for i = 2, tonumber @args["Nbre de termes"]
            a, s = tirer min, delta, relatifs
            q = "#{q} × #{s}"
            r = r * a
          "#{q}\n= ?", "#{r}"
      }
      ["Ordre de grandeur"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre de termes"]: 2
          Relatifs: false
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs = bornes @args
          r, q = tirer min, delta, relatifs, true
          o = pow 10, floor log abs(r), 10
          r = o * round r/o
          rs = "#{r}"
          for i = 2, tonumber @args["Nbre de termes"]
            a, s = tirer min, delta, relatifs
            q = "#{q} × #{s}"
            o = pow 10, floor log abs(a), 10
            a = o * round a/o
            r = r * a
            rs = "#{rs} × " .. (a > 0 and "#{a}" or "(#{a})")
          "#{q}\n≈ ?", "#{rs} = #{r}"
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
global: w, global: {document: doc} = js
gbId = doc\getElementById


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


-------- Procédure --------

body = EL "corps"
body << html -> {
  h1 {a {id:"titre", href:"#", "Calcul mental"}}
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
  div {
    id: "chrono", class: "chrono"
  }
}

bouton = EL "lancer"
chr = EL "chrono"
enonce = EL "enonce"
liste_exercices = EL "liste_exercices"
exercices = EL "exercices"
reponse = EL "reponse"

chrono = (d, s=0) -> w\setTimeout (-> chr < d - t), 1000 * (t + s) for t = 0, d - 1

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
        if type(v) == "boolean"
          td{input {id: "#{titre}_#{k}", type:"checkbox"}}
        else
          td{input {id: "#{titre}_#{k}", value: v}}
      }
  titre_categorie = EL categorie
  titre_categorie.el.onclick = ->
    if liste_categorie.el.style.display == "none"
      liste_categorie.el.style.display = "block"
    else
      liste_categorie.el.style.display = "none"

EL("titre").el.onclick = ->
  enonce < ""
  reponse < ""
  enonce.el.style.display = "none"
  reponse.el.style.display = "none"
  exercices.el.style.visibility = "visible"

bouton.el.onclick = ->
  enonce.el.style.display = "block"
  reponse.el.style.display = "block"
  exercices.el.style.visibility = "hidden"
  enonce < "Prêt ?"
  serie = {}
  t = 4
  chrono t - 1, 1
  for _, categorie in pairs m
    for titre, exo in pairs categorie
      duree = tonumber EL("#{titre}_duree")\value!
      nombre = tonumber EL("#{titre}_nombre")\value!
      continue if nombre < 1
      for arg, val in pairs exo.args
        f = EL("#{titre}_#{arg}").el
        val = f.checked or (f.value != "on" and f.value)
        exo.args[arg] = val
      for n = 1, nombre
        insert serie, {
          fn: exo\fn
          temps: t
          duree: duree
          n_termes: exo.args["Nbre de termes"] or 2
        }
        t = t + duree
  reponses = {}
  for {:fn, :temps, :duree, :n_termes} in *serie
    enonce.el.style["font-size"] = "#{1250/math.sqrt(n_termes)}%"
    q, r = fn!
    insert reponses, {q, r}
    w\setTimeout (->
      w.katex\render q\gsub('\n', [[\\]]), enonce.el, {throwOnError: false}
      chrono duree
    ), 1000 * temps
  w\setTimeout (->
    enonce < "Terminé !"
    chr < ""
  ), 1000 * t
  w\setTimeout (->
    enonce < ""
    reponse < concat [w.katex\renderToString r[1]\gsub("?", "\\textbf{#{r[2]}}") for r in *reponses], "<br>"
  ), 1000 * (t + 3)
