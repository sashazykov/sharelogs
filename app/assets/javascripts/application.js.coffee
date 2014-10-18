#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks
#= require_tree .

sharelogInit = () ->

  html_lines = ansi_up.ansi_to_html($("#code").text()).split(/\r\n|\r|\n/)
  $("#code").html('<table></table>')
  prev = null
  prev_pad = null
  $(html_lines).each (i) ->
    if this.length == 0
      pad = prev_pad
    else if pad = this.match(/^\s+/)
      pad = pad[0].length
    else
      pad = 0

    # prev.append(" #{prev_pad} < #{pad}") if prev
    if prev_pad? && prev_pad < pad
      prev.append(" <a href='#' class='toggle-block-logic open-block'><i class='fa fa-minus-square-o'></i></a>")
    
    # add new line
    prev = $("#code table").append("<tr id='L#{i}' data-pad='#{pad}'><td class='line-number'><a href='#L#{i}'>#{i}</a></td><td class='log'>#{this}</td></tr>").find('tr:last td.log')
    prev_pad = pad 

  grepPid = 1

  grepLogs = () ->
    grepPid += 1
    currentPid = grepPid
    grepString = $('#grepInput').val()
    if grepString == ''
      $("#code table tr").show()
    else
      $("#code table tr").each (i) ->
        if currentPid != grepPid
          return false
        if $(this).find('td').text().match(new RegExp(grepString, "i"))
          $(this).show()
        else
          $(this).hide()

  $('#grepInput').on 'change', grepLogs
  $('#grepInput').on 'keyup', grepLogs

  $(document).on 'click', '.toggle-block-logic', () ->
    line = $(this).parent().parent()
    pad = parseInt(line.data('pad'))
    if $(this).hasClass('open-block')
      next = line.next()
      while next && parseInt(next.data('pad')) > pad
        next.hide()
        next = next.next()
      $(this).removeClass('open-block')
      $(this).find('.fa').removeClass('fa-minus-square-o')
      $(this).find('.fa').addClass('fa-plus-square-o')
    else
      next = line.next()
      while next && parseInt(next.data('pad')) > pad
        next.show()
        next = next.next()
      $(this).addClass('open-block')
      $(this).find('.fa').removeClass('fa-plus-square-o')
      $(this).find('.fa').addClass('fa-minus-square-o')
    return false

$ sharelogInit
$(document).on 'page:load', sharelogInit