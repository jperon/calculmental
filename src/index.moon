import html from require "html"
luajs = require "luajs"
import EL, chrono, co_launch, launch from luajs
:null, global: w, global: {document: doc} = require"js"
import concat, remove from table
import random, sqrt from math

_t = os.clock!
m = require"exercices"
--print  c for c in *m.categories

--print  "--0", os.clock! - _t
bouton = EL "lancer"
chr = EL "chrono"
enonce = EL "enonce"
exercices = EL "exercices"
reponse = EL "reponse"
--print  "--1", os.clock! - _t

chrono = (d, s=0) -> w\setTimeout (-> chr < string.format "%d", d - t), 1000 * (t + s) for t = 0, d - 1

_fn = (categorie) ->
  liste_categorie = EL "#{categorie}_table"
  titre_categorie = EL categorie
  _fait = {}
  titre_categorie\on "click", ->
    if liste_categorie\is_hidden!
      __fn = (titre, exo) ->
        return if _fait["#{titre}{exo}"]
        id_nombre, id_duree = "#{titre}_nombre", "#{titre}_duree"
        liste_categorie << html ->
          label class: "titre", (titre\gsub "_", " ")
          div id: "#{titre}_args", class: "args ctn", ->
            label "&nbsp Nbre", -> input id: id_nombre, value: 0
            label "&nbsp Durée", -> input id: id_duree, value: exo.duree
        el_titre_args = EL("#{titre}_args")
        for k, v in pairs exo.args
          el_titre_args << html ->
            div class: "arg", ->
              label "&nbsp #{k}", ->
                if type(v) == "boolean"
                  input id: "#{titre}_#{k}", type:"checkbox"
                else
                  input id: "#{titre}_#{k}", value: v
        _fait["#{titre}{exo}"] = true
      co_launch [__fn(titre, exo) for titre, exo in pairs m[categorie]], ->
        liste_categorie\show!
    else liste_categorie\hide!


--print  "--2", os.clock! - _t
co_launch [(-> _fn categorie) for categorie in *m.categories], -> launch ->
  bouton\on "click", ->
    exercices\hide!
    enonce\show!
    enonce < "Prêt ?"
    serie = {}
    t = tonumber EL("attente")\value!
    chrono t-1, 1
    for _, categorie in ipairs m.categories
      for titre, exo in pairs m[categorie]
        duree = EL("#{titre}_duree").element
        if duree ~= null
          duree = tonumber(duree.value) or 0
          nombre = tonumber(EL("#{titre}_nombre")\value!) or 0
          continue if nombre < 1
          for arg, val in pairs exo.args
            f = EL("#{titre}_#{arg}").element
            val = f.checked or (f.value ~= "on" and f.value)
            exo.args[arg] = val
          for _i = 1, nombre
            serie[#serie+1] = {
              fn: exo\fn
              duree: duree
              n_termes: exo.args["Nbre_de_termes"] or 2
            }
    reponses = {}
    while #serie > 0
      {:fn, :duree, :n_termes} = remove serie, random #serie
      enonce.element.style["font-size"] = "#{1250/sqrt(n_termes)}%"
      q, r = fn!
      reponses[#reponses+1] = {q, r}
      w\setTimeout (->
        w.katex\render q\gsub('\n', [[\\]]), enonce.element, throwOnError: false
        chrono duree
      ), 1000 * t
      t = t + duree
    w\setTimeout (->
      enonce < "Terminé !"
      chr < ""
    ), 1000 * t
    correction = EL("correction_fin").element
    if correction.checked or (correction.value ~= "on" and correction.value)
      w\setTimeout (->
        enonce < ""
        reponse < concat [w.katex\renderToString r[1]\gsub("?", "\\textbf{\\(%%s\\)}")\format(
            r[2]!
          ) for r in *reponses], "<br/>"
        enonce\hide!
        reponse\show!
      ), 1000 * (t + 3)

  --print  os.clock! - _t

EL("titre")\on "click", ->
  enonce < ""
  reponse < ""
  enonce\hide!
  reponse\hide!
  exercices\show!
--print  "--3", os.clock! - _t
