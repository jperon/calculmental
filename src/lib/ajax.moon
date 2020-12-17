js = require "js"
import new from js
w = window or js.global
import decode, encode from require"json"

ajax = (url, _type, data, dataType, fn) ->
  if not dataType and data
    switch _type
      when 'GET'
        dataType = "application/x-www-form-urlencoded"
      when 'POST'
        dataType = "application/json"
  xhttp = new w.XMLHttpRequest
  xhttp.onreadystatechange = =>
    if self.readyState == 4 and self.status == 200
      fn self.responseText
  xhttp\open _type, url, true
  xhttp\setRequestHeader "Content-type", dataType
  xhttp\send data

get = (url, data, fn) ->
  ajax(url, 'GET', data, "application/x-www-form-urlencoded", fn)

post = (url, data, fn) ->
  ajax(url, 'POST', encode(data), "application/json", (resp) -> fn decode resp)

:ajax, :get, :post
