import EL, html, lancer from dom
global: w, global: {document: doc} = require"js"
import time from os
import concat, insert, remove from table
import random, randomseed, sqrt from math
randomseed(time!)


--------------------- Calcul des énoncés --------------------

local m
do
  MIN = 100
  import abs, ceil, floor, log from math

  pow = (a, n) ->
    return 1 if n == 0
    return a if n == 1
    pow a*a, n/2 if n % 2 == 0 else a * pow a*a, (n-1)/2

  round = (d, decimales) ->
    div = pow 10, (decimales or 0)
    d = d * div
    f = floor d
    f / div if d - f < .5 else (f + 1) / div

  bornes = (args) ->
    div = pow 10, tonumber(args["Décimales"]) or 0
    min = div * tonumber(args.Min or MIN) - 1
    max = div * (tonumber(args.Max) or 10 * min)
    min, max = max, min if min > max
    min, max, max - min, args.Relatifs, div

  tirer = (min, delta, relatifs, div, sansparentheses) ->
    div = div or 1
    r = (min + random delta) * (relatifs and (pow -1, random 2) or 1) / div
    r, ((sansparentheses or r > 0) and "%f" or "(%f)")\format r

  premiers = {2, 3, 5, 7}
  premiers.__index = (t, k) ->
    n = t[k - 1] + 2
    est_premier = false
    while not est_premier
      est_premier = true
      for d in *t
        if n % d == 0
          est_premier = false
          n += 2
          break
    insert t, n
    n
  premiers.__call = (t, par) ->
    i = 0
    local max, lim
    if type(par) == "table"
      {:lim, :max} = par
    else
      lim = par
    lim += 1 if lim
    ->
      i += 1
      if lim and i < lim or max and t[i] <= max
        t[i]
  setmetatable premiers, premiers

  facteurs = (n) ->
    r = floor sqrt n
    fn = premiers{max:r}
    d = fn!
    local fini
    ->
      return if fini
      while d and d <= r
        return if n == 1
        if n % d == 0
          n = n / d
          return d
        else
          d = fn!
      fini = true
      floor n

  m = {
    ["Addition"]:
      ["Somme"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre_de_termes"]: 2
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs, div = bornes @args
          r, q = tirer min, delta, relatifs, div, true
          for i = 2, tonumber @args["Nbre_de_termes"]
            a, s = tirer min, delta, relatifs, div
            q = "#{q} + #{s}"
            r = r + a
          "#{q}\n= ?", ->
            "%f"\format r
      }
      ["Additions_soustractions"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre_de_termes"]: 3
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          n_termes = tonumber @args["Nbre_de_termes"]
          min, max, delta, relatifs, div = bornes @args
          r, q = tirer min, delta, relatifs, div, true
          for i = 2, n_termes
            min, delta = -r, (max + r > 1 and max + r or 2) if not relatifs and i == n_termes and r < 0 and -r > min
            a, s = tirer min, delta, relatifs, div
            soustraction = (relatifs or (r + a > -max and i < n_termes) or r - a > 0) and pow(-1, random 2) == -1
            q = q .. (soustraction and " - #{s}" or " + #{s}")
            r = r + (soustraction and -a or a)
          "#{q}\n= ?", ->
            "%f"\format r
      }
    ["Soustraction"]:
      ["Différence"]: {
        args: {
          Min: 10
          Max: 100
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs, div = bornes @args
          a, q = tirer min, delta, relatifs, div, true
          delta = a - min if not relatifs and max > a
          b, s = tirer min, delta, relatifs, div
          "#{q} - #{s}\n= ?", ->
            "%f"\format a - b
      }
      ["Complément"]: {
        args: {
          Min: 10
          Ref: 100
        }
        duree: 8
        fn: =>
          min, max, delta = bornes {Min: @args.Min, Max: @args.Ref}
          a = min + random delta
          "#{a} + ?\n= #{max}", ->
            "%f"\format max - a
      }
    ["Multiplication"]:
      ["Produit"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre_de_termes"]: 2
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs, div = bornes @args
          r, q = tirer min, delta, relatifs, div, true
          for i = 2, tonumber @args["Nbre_de_termes"]
            a, s = tirer min, delta, relatifs, div
            q = "#{q} × #{s}"
            r = r * a
          "#{q}\n= ?", ->
            "%f"\format round r, 2 * tonumber @args["Décimales"]
      }
      ["Ordre_de_grandeur"]: {
        args: {
          Min: 10
          Max: 100
          ["Nbre_de_termes"]: 2
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs, div = bornes @args
          r, q = tirer min, delta, relatifs, div, true
          o = pow 10, floor log abs(r), 10
          r = o * round r/o
          rs = "%f"\format r
          for i = 2, tonumber @args["Nbre_de_termes"]
            a, s = tirer min, delta, relatifs, div
            q = "%s × %s"\format q, s
            o = pow 10, floor log abs(a), 10
            a = o * round a/o
            r = r * a
            rs = "#{rs} × " .. (a > 0 and "%f" or "(%f)")\format a
          "#{q}\n≈ ?", ->
            "#{rs} = %f"\format r
      }
      ["Identités_remarquables"]: {
        args: {
          a: 100
          b: 10
        }
        duree: 8
        fn: =>
          min, max, delta = bornes {Min:@args.b, Max:@args.a}
          ordre_max = pow(10, floor (log(max, 10) - 1))
          c = ordre_max * random ceil(max/ordre_max)
          d = random min
          a = c + d
          b = c - d
          "#{a} × #{b} \n= ?", ->
            "#{c}^2 - #{d}^2 = #{a * b}"
      }
      ["Multiplication_astucieuse"]: {
        args: {
          Base: 100
          ["Différence"]: 10
        }
        duree: 8
        fn: =>
          min, max, delta = bornes {Min:@args["Différence"], Max:@args.Base}
          ordre_max = pow(10, floor log(max, 10))
          ordre_min = pow(10, floor log(min, 10))
          delta_max = max/ordre_max * ceil(delta/ordre_max/10)
          ordre_max, delta_max = ordre_max/10, delta_max * 10 if delta_max < 3
          c = floor ordre_max * random(delta_max)
          diff = ordre_min * random ceil(min/ordre_min)
          d = floor random diff
          a = floor c + d
          b = floor c - d + diff
          "#{a} × #{b} \n= ?", ->
            "#{c} \\times #{c + diff} + #{d} \\times #{diff - d} = #{a * b}"
      }
    ["Division"]:
      ["Quotient"]: {
        args: {
          Min: 2
          Max: 400
          Relatifs: false
          ["Décimales"]: 0
        }
        duree: 8
        fn: =>
          min, max, delta, relatifs, div = bornes @args
          d = tirer min, ceil(2 * sqrt delta), relatifs, div, true
          delta = floor(max/d) - min
          delta = 2 if delta < 1
          n = d * tirer min, delta, relatifs, div, true
          decimales = 2 * tonumber @args["Décimales"]
          n, d = round(n, decimales), round(d, decimales)
          "\\frac{%f}{%f}\n= ?"\format(n, d), ->
            "%f"\format round(n / d, decimales)
      }
      ["Division_astucieuse"]: {
        args: {
          Min: 10
          Max: 1000
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          d = min + random floor sqrt delta
          delta = floor(max / d) - min
          dn = delta < 20 and 1 or floor(delta/10)
          dd = delta < 70 and 3 or floor(delta/20)
          na = d * 10 * random dn
          ns = pow(-1, random 2)
          nb = d * random dd
          n = na + ns * nb
          "\\frac{%f}{%f} \n= ?"\format(n, d), ->
            "\\frac{%f %s %f}{%d} = %f"\format na, ns == 1 and "+" or "-", nb, d, n/d
      }
      ["Division_euclidienne"]: {
        args: {
          Min: 2
          Max: 200
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          d = tirer min, ceil(2 * sqrt delta)
          n = tirer d, max - d
          "%f = %f × ? + ?"\format(n, d), ->
            floor(n / d), floor n % d
      }
    ["Arithmétique"]:
      ["Décomposition_en_facteurs_premiers"]: {
        args: {
          Min: 2
          Max: 200
        }
        duree: 8
        fn: =>
          min, max, delta = bornes @args
          n = floor tirer min, delta
          "#{n} = ?", ->
            concat [d for d in facteurs n], ' × '
      }
  }


-------- Procédure --------

body = EL "corps"
body\replace html -> {
  h1 {a {id:"titre", href:"#", "Calcul mental"}}
  div {
    id: "exercices"
    div {
      div {
        class: "ctn"
        label {
          "Délai avant de commencer"
          input {id: "attente", class: "args", value: 3}
        }
      }
      div {
        class: "ctn"
        label {
          "Correction à la fin"
          input {id: "correction_fin", type: "checkbox", checked: true}
        }
      }
    }
    div {
      id: "liste_exercices"
    }
    "&nbsp"
    button {id: "lancer", "C'est parti !"}
    div {
      id: "note_version"
      class: "note_version"
      p {"Version #{doc\querySelector('meta[name="version"]').content}"}
    }
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
  lancer ->
    for titre, exo in pairs operation
      id_nombre, id_duree = "#{titre}_nombre", "#{titre}_duree"
      liste_categorie << html -> {
        label {class: "titre", (titre\gsub "_", " ")}
        div {
          id: "#{titre}_args"
          class: "args ctn"
          label {"&nbsp Nbre", input {id: id_nombre, value: 0}}
          label {"&nbsp Durée", input {id: id_duree, value: exo.duree}}
        }
      }
      el_titre_args = EL("#{titre}_args")
      lancer ->
        for k, v in pairs exo.args
          el_titre_args << html -> {
            div {
              class: "arg"
              label {
                "&nbsp #{k}"
                if type(v) == "boolean"
                  input {id: "#{titre}_#{k}", type:"checkbox"}
                else
                  input {id: "#{titre}_#{k}", value: v}
              }
            }
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
  t = EL("attente")\value!
  chrono t - 1, 1
  for _, categorie in pairs m
    for titre, exo in pairs categorie
      duree = tonumber(EL("#{titre}_duree")\value!) or 0
      nombre = tonumber(EL("#{titre}_nombre")\value!) or 0
      continue if nombre < 1
      for arg, val in pairs exo.args
        f = EL("#{titre}_#{arg}").el
        val = f.checked or (f.value != "on" and f.value)
        exo.args[arg] = val
      for _ = 1, nombre
        insert serie, {
          fn: exo\fn
          duree: duree
          n_termes: exo.args["Nbre_de_termes"] or 2
        }
  reponses = {}
  while #serie > 0
    {:fn, :duree, :n_termes} = remove serie, random #serie
    enonce.el.style["font-size"] = "#{1250/sqrt(n_termes)}%"
    q, r = fn!
    insert reponses, {q, r}
    w\setTimeout (->
      w.katex\render q\gsub('\n', [[\\]]), enonce.el, {throwOnError: false}
      chrono duree
    ), 1000 * t
    t = t + duree
  w\setTimeout (->
    enonce < "Terminé !"
    chr < ""
  ), 1000 * t
  correction = EL("correction_fin").el
  if correction.checked or (correction.value != "on" and correction.value)
    w\setTimeout (->
      enonce < ""
      reponse < concat [w.katex\renderToString r[1]\gsub("?", "\\textbf{\\(%%s\\)}")\format(
          r[2]!
        ) for r in *reponses], "<br>"
    ), 1000 * (t + 3)
