#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks
#= require_tree .

$ () ->

  html_lines = ansi_up.ansi_to_html($("#code").text()).split(/\r\n|\r|\n/)
  $("#code").html('<table></table>')
  $(html_lines).each (i) ->
    $("#code table").append("<tr id='L#{i}'><td class='line-number'><a href='#L#{i}'>#{i}</a></td><td>#{this}</td></tr>")