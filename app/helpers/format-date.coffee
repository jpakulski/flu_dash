`import Ember from 'ember'`

pad = (val)->
  return if val < 10 then "0#{val}" else "#{val}"

FormatDateHelper = Ember.Helper.helper (d)->
  d = d[0]
  "#{pad(d.getDate())}/#{pad(d.getMonth() + 1)}/#{d.getFullYear()}" if d? and (typeof d.getDate == "function")

`export default FormatDateHelper`
