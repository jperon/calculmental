#!/usr/bin/env moon

page = io.open "interface.html"
contenu = page\read "*a"
page\close!

for n in contenu\gmatch "{{(.-)}}" do
  f = io.open n
  ct = f\read("*a")\gsub("%%", "%%%%")
  contenu, a, b = contenu\gsub "{{#{n}}}", ct
  f\close!

sortie = io.open "mental.html", "w"
sortie\write contenu
sortie\close
