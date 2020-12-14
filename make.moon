#!/usr/bin/env moon
package.path = "src/?.lua;#{package.path}"
import wrap, yield from coroutine
import open, stderr from io
import date, execute, exit from os
import concat, sort from table
import attributes, dir, mkdir from require "lfs"

DIST = "dist"
SRC = "src"
TEMPLATES = "templates"

OPTIONS = {
  start_url: "/"
  version: date "%y%m%d%H%M"
}

err = (...) -> stderr\write("#{concat({...}, " ")}\n")

opairs = (t, fn) ->
  _t = [k for k in pairs t]
  sort _t, fn
  wrap -> yield k, t[k] for k in *_t


do
  mandatory_options = ['    --'..k..'='..k\upper! for k, v in opairs OPTIONS when not v]
  other_options = ['    --'..k..'='..k\upper!..'  ('..v..')' for k, v in opairs OPTIONS when v]
  mandatory = "\n\n  Mandatory options:#{#mandatory_options > 0 and "\n" .. concat(mandatory_options, '\n') or ' none'}" or ""
  other = #other_options > 0 and "\n\n  Other options:\n#{concat other_options, '\n'}" or ""
  export USAGE = "Usage: #{arg[0]} [OPTIONS]#{mandatory}#{other}"
do
  for opt in *arg
    if opt == "-h" or opt == "--help"
      print(USAGE)
      exit 0
    k, v = opt\match("%-%-(.*)=(.*)")
    if OPTIONS[k] ~= nil
      OPTIONS[k] = v
    else
      err "Unknown argument: #{k}.\n\n#{USAGE}"
      exit 1
  ok = true
  for k in pairs OPTIONS
    unless OPTIONS[k]
      err "Missing mandatory argument: #{k}."
      ok = false
  unless ok
    err "\n#{USAGE}"
    exit 1


do
  execute "moonc #{SRC}/*.moon"
  ct = require("#{SRC}/interface") OPTIONS
  sortie = assert open "#{DIST}/index.html", "w"
  sortie\write ct
  sortie\close!


fill_options = (input_dir, output_dir) ->
  for template in dir input_dir
    continue if template\match "^%."
    input_path = "#{input_dir}/#{template}"
    output_path = "#{output_dir}/#{template}"
    switch attributes input_path, "mode"
      when "directory"
        mkdir output_path
        fill_options input_path, output_path
      when "file"
        input = assert open input_path, "r"
        ct = input\read"*a"
        input\close!
        for k in ct\gmatch "<<<(.-)>>>"
          if OPTIONS[k]
            print(k, OPTIONS[k])
            ct = ct\gsub "<<<#{k}>>>", OPTIONS[k]
        output = assert open output_path, "w"
        output\write ct
        output\close!

fill_options TEMPLATES, DIST
