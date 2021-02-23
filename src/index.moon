import html from require"lib.html"
import open from io
import date from os
import sort from table
m = require"lib.exercices"

STATIC = './static'

opairs = (fn) =>
  _k = [k for k in pairs @]
  sort _k, fn
  i = 0
  ->
    i += 1
    k = _k[i]
    k, @[k]

read = =>
  f = open(@) or open("src/#{@}") or open("src/lib/#{@}")
  r = f\read"*a"
  f\close! and r

load_lua = => "package.loaded[\"#{@}\"] = (function() #{read(@..'.lua')\gsub('[%s]*%-%-.-\n', '\n')\gsub('[\n]+', '\n')} end)()\n"

categories = -> html ->
  for categorie in *m.categories
    h2 id: categorie, -> a href:"#", categorie
    div id: "#{categorie}_table", style: "display:none;", ->
      for titre, exo in opairs m[categorie]
        label class: "titre", (titre\gsub "_", " ")
        div id: "#{titre}_args", class: "args ctn", ->
          label "&nbsp Nbre", -> input id: "#{titre}_nombre", value: 0
          label "&nbsp Durée", -> input id: "#{titre}_duree", value: exo.duree
          for k, v in opairs exo.args
            div class: "arg", ->
              label "&nbsp #{k}", ->
                if type(v) == "boolean"
                  input id: "#{titre}_#{k}", type:"checkbox"
                else
                  input id: "#{titre}_#{k}", value: v

(infos = {}) ->
  version = infos.version or date "%y%m%d%H%M"
  html ->
    text "<!DOCTYPE html>"
    _html lang:"fr", ->
      head ->
        meta charset:"utf-8"
        meta name:"viewport", content:"width=device-width, initial-scale=1"
        meta name:"theme-color", content:"black"
        meta name:"robots", content:"none"
        link rel:"manifest", href:"#{STATIC}/manifest.json"
        link rel:"icon", href:"#{STATIC}/favicon.ico", type:"image/x-icon"
        link rel:"apple-touch-icon", href:"#{STATIC}/icon.png"
        link rel:"preload", href:"#{STATIC}/katex.min.css", as:"style", onload:"this.onload=null;this.rel='stylesheet'"
        noscript -> link rel:"stylesheet", href:"#{STATIC}/katex.min.css"
        title "Calcul mental"
        meta name:"description", content:"Application de calcul mental"
        meta name:"version", content:"#{version}"
      body ->
        style ->
          text read "style.css"
          -- text read "katex.min.css"
        div id:"corps", style: "display:block;", ->
          h1 -> a id:"titre", href:"#", "Calcul mental"
          div id: "exercices", ->
            div id:"parametres", class: "ctn", -> label "Délai avant de commencer", ->
              input id: "attente", class: "args", value: 3
              text "&nbsp"
              button id: "oral", "Oral"
              br!
              label "Correction à la fin", -> input id: "correction_fin", type: "checkbox", checked: true
              br!
              text "&nbsp"
            div id: "liste_exercices", style: "display:block;", -> text categories!
            div id: "note_version", class: "note_version", -> p "Version #{version}"
          div id: "question", class: "zone", -> p id: "enonce"
          div id: "reponse", class: "zone", ""
          div id: "chrono", class: "chrono", ""
        script type:"application/lua", ->
          -- text load_lua "html"
          -- text load_lua "json"
          text load_lua "luajs"
          text load_lua "exercices"
          text read "app.lua"
        script type:"application/javascript", src:"#{STATIC}/fengariWeb.js", "" -- -> text read "fengariWeb.js"
        script type:"application/javascript", src:"#{STATIC}/katex.min.js", async:true, "" -- -> text read "katex.min.js"
        script type:"application/javascript", src:"#{STATIC}/install_sw.js", async:true, "" -- "if ('serviceWorker' in navigator) {window.addEventListener('load', () => {navigator.serviceWorker.register('sw.js').catch(err => {console.log(`Echec de l'enregistrement du Service Worker: ${err}`);});});}"
