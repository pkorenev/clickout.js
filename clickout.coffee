window.click_out_subscribers = []

get_elements = (subscriber)->

resolve_elems = (subscriber)->
  $elems = null
  if subscriber.selector
    $elems = $(subscriber.selector)
  else if subscriber.element
    $elems = $(subscriber.element)
  else if typeof subscriber.element_function == 'function'
    $elems = subscriber.element_function.call(this)

  $elems

except_elements = (target, subscriber)->
  $elems = resolve_elems(subscriber)

  if (excepted_elements = subscriber.options.except)
    if typeof excepted_elements == 'string'
      $elems = $elems.filter(
        (index, item)->
          $elem = $(this)
          $elem.closest(excepted_elements).length > 0
      )

      $filtered_elems = $elems.filter(
        (index, item)->
          $elem = $(this)
          $elem.closest(excepted_elements).length == 0
      )

      selectors_count = excepted_elements.split(",")
      i = 0

      $excepted_elements = $(excepted_elements)
      $untargeted_excepted_elements = $excepted_elements.filter(
        (index, item)->
          $elem = $(this)
          $(target).closest($elem).length > 0
      )

      return $untargeted_excepted_elements
    else if typeof excepted_elements == 'function'
      return excepted_elements.call(target, subscriber)

  else
    return []

$document.on "click", (e)->
  $target = $(e.target)
  for s in click_out_subscribers
    $elems = resolve_elems(s)
    $untargeted_excepted_elements = except_elements(e.target, s)

    $untargeted_elems = $elems.filter(
      (index, item)->
        $elem = $(item)
        $target.closest($elem).length == 0
    )

    if $untargeted_elems.length > 0 && $untargeted_excepted_elements.length == 0
      $untargeted_elems.each (elem)->
        s.options.handler.call(this, s)
    else
      continue

$.clickOut = (elem_or_selector_or_function, options_or_handler = {}, options = {})->
  $elem = $(elem_or_selector_or_function)

  subscriber = {}
  if typeof elem_or_selector_or_function == 'string'
    subscriber.selector = elem_or_selector_or_function
  else if typeof elem_or_selector_or_function == 'function'
    subscriber.element_function = elem_or_selector_or_function
  else
    subscriber.element = elem_or_selector_or_function

  if typeof options_or_handler == 'function'
    options['handler'] = options_or_handler

  subscriber.options = options

  click_out_subscribers.push(subscriber)
