#!/usr/bin/env moon-jit

page = io.open "interface.html"
contenu = page\read "*a"
page\close!

for n in contenu\gmatch "{{(.-)}}" do
  f = io.open n
  contenu = contenu\gsub "{{#{n}}}", f\read("*a")\gsub("%%", "%%%%")
  f\close!

sortie = io.open "mental.html", "w"
sortie\write contenu
sortie\close
