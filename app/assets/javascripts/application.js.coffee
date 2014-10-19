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
    i++
    if this.length == 0
      pad = prev_pad
    else if pad = this.match(/^\s+/)
      pad = pad[0].length
    else
      pad = 0

    # prev.append(" #{prev_pad} < #{pad}") if prev
    if prev_pad? && prev_pad < pad
      prev.append(" <i class='fa fa-minus-square-o toggle-block-logic'></i>")
    
    # add new line
    prev = $("#code table").append("<tr id='L#{i}' data-pad='#{pad}'><td class='line-number'><a href='#L#{i}'>#{i}</a></td><td class='log'>#{this}</td></tr>").find('tr:last td.log')
    prev_pad = pad 

  grepPid = 1

  grepLogs = () ->
    grepPid += 1
    currentPid = grepPid
    grepString = $('#grepInput').val()
    if grepString == ''
      $("#code table tr").removeClass('hidden-by-grep')
    else
      $("#code table tr").each (i) ->
        if currentPid != grepPid
          return false
        if $(this).find('td').text().match(new RegExp(grepString, "i"))
          $(this).removeClass('hidden-by-grep')
        else
          $(this).addClass('hidden-by-grep')

  $('#grepInput').on 'change', grepLogs
  $('#grepInput').on 'keyup', grepLogs

  if selected_line = location.hash.match(/L\d+/)
    $('#'+selected_line[0]).addClass('highlighted')


# end of sharelogInit

$(document).on 'click', '.toggle-block-logic', () ->
  line = $(this).parent().parent()
  pad = parseInt(line.data('pad'))
  if $(this).hasClass('fa-minus-square-o')
    next = line.next()
    while next && parseInt(next.data('pad')) > pad
      next.addClass('hidden-by-fold')
      next = next.next()
    $(this).removeClass('fa-minus-square-o')
    $(this).addClass('fa-plus-square-o')
  else
    next = line.next()
    while next && parseInt(next.data('pad')) > pad
      next.removeClass('hidden-by-fold')
      next = next.next()
    $(this).removeClass('fa-plus-square-o')
    $(this).addClass('fa-minus-square-o')

$(document).on 'click', '.line-number', () ->
  $("#code table tr").removeClass('highlighted')
  $(this).parent().addClass('highlighted')
  # location.hash = $(this).parent().attr('id')
  history.pushState('', document.title, window.location.pathname + '#' + $(this).parent().attr('id'));
  e.preventDefault()

$ sharelogInit
$(document).on 'page:load', sharelogInit