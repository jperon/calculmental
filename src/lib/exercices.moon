import random, randomseed, sqrt from math
import time from os
import concat from table
randomseed time!

MIN = 100
import abs, ceil, floor, log from math

pow = (n) => n == 0 and 1 or n == 1 and @ or n % 2 == 0 and pow @*@, n/2 or @ * pow @*@, (n-1)/2

round = (decimales=0) =>
  div = pow 10, decimales
  floor(@ * div + .5) / div

bornes = (args) ->
  div = pow 10, tonumber(args["Décimales"]) or 0
  min = div * tonumber(args.Min or MIN) - 1
  max = div * (tonumber(args.Max) or 10 * min)
  min, max = max, min if min > max
  min, max, max - min, args.Relatifs, div

tirer = (min, delta, relatifs, div=1, sansparentheses) ->
  r = (min + random delta) * (relatifs and (pow -1, random 2) or 1) / div
  r, ((sansparentheses or r > 0) and "%f" or "(%f)")\format r

premiers = {2, 3, 5, 7}
premiers.__index = (k) =>
  n = @[k - 1] + 2
  local non_premier
  while non_premier
    for d in *@
      non_premier = n % d == 0
      break if non_premier
      n += 2
  @[#@+1] = n
  n
premiers.__call = (par) =>
  i = 0
  local max, lim
  if type(par) == "table"
    {:lim, :max} = par
  else
    lim = par
  lim += 1 if lim
  ->
    i += 1
    if lim and i < lim or max and @[i] <= max
      @[i]
setmetatable premiers, premiers

facteurs = =>
  r = floor sqrt @
  fn = premiers{max:r}
  d = fn!
  local fini
  ->
    return if fini
    while d and d <= r
      return if @ == 1
      if @ % d == 0
        @ = @ / d
        return d
      else
        d = fn!
    fini = true
    floor @

{
  categories: {"Addition", "Soustraction", "Multiplication", "Division", "Arithmétique"}
  ["Addition" ]: {
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
        min, _, delta, relatifs, div = bornes @args
        r, q = tirer min, delta, relatifs, div, true
        for i = 2, tonumber @args["Nbre_de_termes"]
          a, s = tirer min, delta, relatifs, div
          q = "#{q} + #{s}"
          r = r + a
        "#{q}\n= ?", -> "%f"\format r
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
        "#{q}\n= ?", -> "%f"\format r
    }
  }
  ["Soustraction" ]: {
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
        "#{q} - #{s}\n= ?", -> "%f"\format a - b
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
        "#{a} + ?\n= #{max}", -> "%f"\format max - a
    }
  }
  ["Multiplication" ]: {
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
        min, _, delta, relatifs, div = bornes @args
        r, q = tirer min, delta, relatifs, div, true
        for i = 2, tonumber @args["Nbre_de_termes"]
          a, s = tirer min, delta, relatifs, div
          q = "#{q} × #{s}"
          r = r * a
        "#{q}\n= ?", -> "%f"\format round r, 2 * tonumber @args["Décimales"]
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
        min, _, delta, relatifs, div = bornes @args
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
        "#{q}\n≈ ?", -> "#{rs} = %f"\format r
    }
    ["Identités_remarquables"]: {
      args: {
        a: 100
        b: 10
      }
      duree: 8
      fn: =>
        min, max, _ = bornes {Min:@args.b, Max:@args.a}
        ordre_max = pow(10, floor (log(max, 10) - 1))
        c = ordre_max * random ceil(max/ordre_max)
        d = random min
        a = c + d
        b = c - d
        "#{a} × #{b} \n= ?", -> "#{c}^2 - #{d}^2 = #{a * b}"
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
        "#{a} × #{b} \n= ?", -> "#{c} \\times #{c + diff} + #{d} \\times #{diff - d} = #{a * b}"
    }
  }
  ["Division" ]: {
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
        "\\frac{%f}{%f}\n= ?"\format(n, d), ->  "%f"\format round(n / d, decimales)
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
        "\\frac{%f}{%f} \n= ?"\format(n, d), -> "\\frac{%f %s %f}{%d} = %f"\format na, ns == 1 and "+" or "-", nb, d, n/d
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
        "%f = %f × ? + ?"\format(n, d), -> floor(n / d), floor n % d
    }
  }
  ["Arithmétique" ]: {
    ["Décomposition_en_facteurs_premiers"]: {
      args: {
        Min: 2
        Max: 200
      }
      duree: 8
      fn: =>
        min, _, delta = bornes @args
        n = floor tirer min, delta
        "#{n} = ?", -> concat [d for d in facteurs n], ' × '
    }
  }
}