#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require moment
#= require bootstrap-datetimepicker
#= require turbolinks
#= require_tree .

sharelogInit = () ->

  filterByCheckbox = (name) ->
    selected = []
    selected_checkboxes = $("##{name}s label input:checked")
    selected_checkboxes.each (i) ->
      selected.push($(this).data(name))

    $("#code table tr").each (i) ->
      value = $(this).data(name)

      if (selected.length > 0) && ($.inArray(value, selected) < 0)
        $(this).addClass("hidden-by-#{name}")
      else
        $(this).removeClass("hidden-by-#{name}")

  create_checkbox = (name, value) ->
    data = {}
    data[name] = value
    $("##{name}s").append(
      $('<div></div>').addClass('checkbox').append(
        $('<label></label>').append(
          $('<input/>').attr(type: "checkbox", autocomplete: "off").data(data).on(
            "click", () ->
              filterByCheckbox(name)
          )
        ).append(value)
      )
    )


  html_lines = ansi_up.ansi_to_html($("#code").text()).split(/\r\n|\r|\n/)
  $("#code").html('<table></table>')

  methods = urls = ips = []
  prev = prev_pad = url = method = ip = datetime = datetime_max = null

  datetime_min = new Date('2100-01-01') #far future

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
    pattern = new RegExp(/Started\s(GET|POST|PUT|DELETE|PATCH)\s\"(.*)\"\sfor\s(.*)\sat\s(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\s[+-]\d{4})/g)
    res = pattern.exec(this)
    if res && res.length == 5
      datetime = Date.parse((res[4].substr(0, 19)+res[4].substr(20)).replace(' ', 'T'))
      datetime_max = new Date(Math.max(datetime, datetime_max))
      datetime_min = new Date(Math.min(datetime, datetime_min))
      method = res[1]
      url = res[2]
      ip = res[3]

      if $.inArray(method,methods) < 0
        methods.push(method)
        create_checkbox('method', method)

      if (!url.match('^/assets/')) && ($.inArray(url,urls) < 0)
        urls.push(url)
        create_checkbox('url', url)

      if $.inArray(ip,ips) < 0
        ips.push(ip)
        create_checkbox('ip', ip)

    line.data
      pad: pad
      method: method
      url: url
      ip: ip
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

  filterStatic = () ->
    is_filter_enabled = $("input#static:checked").length > 0
    $("#code table tr").each (i) ->
      url = $(this).data("url")
      if (is_filter_enabled && url && url.match('^/assets/'))
        $(this).addClass('hidden-by-datetime')
      else
        $(this).removeClass('hidden-by-datetime')

  $("#static").on 'click', filterStatic


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


resetFilters = () ->
  $('input').not(':button, :submit, :reset, :hidden')
  .val('')
  .removeAttr('checked')
  .removeAttr('selected')

  $('#code table tr').attr(class: '')

$(document).on 'click', '#code table tr a', (e) ->
  resetFilters()
  $("#code table tr").removeClass('highlighted')
  $(this).parent().parent().addClass('highlighted')
  location.hash = $(this).parent().parent().attr('id')
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