luajs = require "luajs"
import EL, chrono, launch from luajs
:null, global: w = require"js"
import concat, remove from table
import min, random, floor from math

-- _t = os.clock!
-- print "--0", os.clock! - _t

m = require"exercices"

-- print "--1", os.clock! - _t

for categorie in *m.categories
  launch ->
    EL(categorie)\on "click", ->
      liste_categorie = EL"#{categorie}_table"
      liste_categorie\show! if liste_categorie\is_hidden! else liste_categorie\hide!
    -- print "--2", os.clock! - _t

launch ->
  oral, chr, enonce, exercices = EL"oral", EL"chrono", EL"enonce", EL"exercices"
  chrono = (d, s=0) -> launch 1000 * (t + s), (-> chr < string.format "%d", d - t) for t = 0, d - 1
  oral\on "click", ->
    exercices\hide!
    enonce\show!
    enonce < "Prêt ?"
    serie = {}
    t = tonumber EL"attente".value
    chrono t-1, 1
    for categorie in *m.categories
      for titre, exo in pairs m[categorie]
        duree = EL"#{titre}_duree".element
        if duree ~= null
          duree = tonumber(duree.value) or 0
          nombre = tonumber(EL"#{titre}_nombre".value) or 0
          continue if nombre < 1
          for arg, val in pairs exo.args
            f = EL"#{titre}_#{arg}"
            val = f.checked or (f.value ~= "on" and f.value)
            exo.args[arg] = val
          for _i = 1, nombre
            serie[#serie+1] = fn: exo\fn, duree: duree
    reponses = {}
    while #serie > 0
      {:fn, :duree} = remove serie, random #serie
      local q, r, ok
      n = 0
      while not ok and n < 100
        n += 1
        q, r = fn!
        ok = true
        for {qq} in *reponses
          if qq == q
            ok = false
            break
      reponses[#reponses+1] = {q, r}
      reponses.fontsize = min(floor(150/#q), reponses.fontsize or 20)
      launch 1000*t, ->
        fontsize = min(20, floor 200/#q)
        enonce.style["font-size"] = "#{fontsize}vw"
        w.katex\render q\gsub('\n', [[\\]])\gsub('\\percent', '\\%%'), enonce.element, throwOnError: false
        chrono duree
      t += duree
    launch 1000*t, ->
      enonce < "Terminé !"
      chr < ""
    correction = EL"correction_fin"
    if correction.checked or (correction.value ~= "on" and correction.value)
      launch 1000*(t+3), ->
        reponse = EL"reponse"
        reponse.style["font-size"] = "#{reponses.fontsize}vw"
        enonce < ""
        reponse < concat [w.katex\renderToString r[1]\gsub("?", "\\textbf{\\(%%s\\)}")\format(
            r[2]!
          )\gsub("\\percent", "\\%%") for r in *reponses], "<br/>"
        enonce\hide!
        reponse\show!
  -- print "--3", os.clock! - _t

launch ->
  enonce = EL"enonce"
  exercices = EL"exercices"
  reponse = EL"reponse"
  EL"titre"\on "click", ->
    enonce < ""
    reponse < ""
    enonce\hide!
    reponse\hide!
    exercices\show!
  -- print "--4", os.clock! - _t
