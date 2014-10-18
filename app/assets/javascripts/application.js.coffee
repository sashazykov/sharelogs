#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks
#= require_tree .

$ () ->

  txt = $("#code").html()
  html = ansi_up.ansi_to_html(txt)
  html_lines = html.split(/\r\n|\r|\n/)
  html_numbered = "<table>"
  line_n = 0
  i = 0
  while i < html_lines.length
    html_numbered += "<tr id=\"L" + i + "\"><td class=\"line-number\"><a href=\"#L" + i + "\">" + i + "</a></td><td>" + html_lines[i] + "</td></tr>"
    i++
  html_numbered += "</table>"
  cdiv = $("#code").html(html_numbered)