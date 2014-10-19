#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require moment
#= require bootstrap-datetimepicker
#= require turbolinks
#= require_tree .

sharelogInit = () ->

  html_lines = ansi_up.ansi_to_html($("#code").text()).split(/\r\n|\r|\n/)
  $("#code").html('<table></table>')
  prev = null
  prev_pad = null
  datetime = datetime_max = null
  datetime_min = 2413480333000
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

    line = $('<tr></tr>').attr(id: "L#{i}")

    # prepare data-attributes
    pattern = new RegExp(/Started\sGET\s\"(.*)\"\sfor\s(.*)\sat\s(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\s[+-]\d{4})/g)
    res = pattern.exec(this)
    if res && res.length == 4
      datetime = Date.parse((res[3].substr(0, 19)+res[3].substr(20)).replace(' ', 'T'))
      datetime_max = new Date(Math.max(datetime, datetime_max))
      datetime_min = new Date(Math.min(datetime, datetime_min))
      line = line.data
        url:      res[1]
        ip:       res[2]

    line.data
      pad: pad
      datetime: datetime

    line.append "<td class='line-number'><a href='#L#{i}'>#{i}</a></td><td class='log'>#{this}</td>"

    # add new line
    prev = $("#code table").append(line).find('tr:last td.log')
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

  datetimepicker_options =
    format: 'MM/DD/YYYY HH:mm:ss'
    useSeconds: true
    pick12HourFormat: false
    minDate: moment(datetime_min).startOf('day')
    maxDate: moment(datetime_max).endOf('day')
    minuteStepping:1
    secondStepping:1
    useStrict: true
    sideBySide: true
    useCurrent: false
    icons:
      time: "fa fa-clock-o"
      date: "fa fa-calendar"
      up: "fa fa-arrow-up"
      down: "fa fa-arrow-down"

  $("#start_time").datetimepicker $.extend(datetimepicker_options,
    defaultDate: datetime_min
  )
  
  $("#end_time").datetimepicker $.extend(datetimepicker_options,
    defaultDate: datetime_max
  )

  $("#start_time input").val("")
  $("#end_time input").val("")
  
  console.log(datetime_min)
  console.log(datetime_max)

  $("#start_time").on "dp.change", (e) ->
    $("#end_time").data("DateTimePicker").setMinDate e.date
    filterTime()
    return

  $("#end_time").on "dp.change", (e) ->
    $("#start_time").data("DateTimePicker").setMaxDate e.date
    filterTime()
    return

  filterTime = () ->    
    start_time = $("#start_time").data("DateTimePicker").getDate()
    
    start_time = null if $("#start_time input").val()==""

    end_time = $("#end_time").data("DateTimePicker").getDate()
    end_time = null if $("#end_time input").val()==""


    $("#code table tr").each (i) ->
      datetime = $(this).data("datetime")

      if (datetime < start_time) ||
         (end_time && (datetime > end_time))
        $(this).addClass('hidden-by-datetime')
      else
        $(this).removeClass('hidden-by-datetime')

  return


# end of sharelogInit

$(document).on 'click', '.toggle-block-logic', (e) ->
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
  return false

$(document).on 'click', '#code table tr', (e) ->
  if $(this).hasClass('highlighted')
     $(this).removeClass('highlighted')
     history.pushState('', document.title, window.location.pathname);
  else
    $("#code table tr").removeClass('highlighted')
    $(this).addClass('highlighted')
    # location.hash = $(this).parent().attr('id')
    history.pushState('', document.title, window.location.pathname + '#' + $(this).attr('id'));
  e.preventDefault()

$ sharelogInit
$(document).on 'page:load', sharelogInit