# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Pusher.log = (message) ->
  console.log message
  return

quota = 2

pusher = new Pusher('885cb9dcf5e442cbfe46',
  authEndpoint: '/auth'
  auth: headers: 'X-CSRF-Token': '<%= form_authenticity_token %>')
presenceChannel = pusher.subscribe('presence-cookies-channel')

presenceChannel.bind 'pusher:subscription_succeeded', (members) ->
  console.log "There are " + members.count + " in this channel"
  return

presenceChannel.bind 'pusher:member_removed', (member) ->
  me = presenceChannel.members.me
  members_count = presenceChannel.members.count

  if members_count < quota
    $('#request-status').html "Your " + me.info + " cookie is READY!"
    return
  return

presenceChannel.bind 'pusher:subscription_error', (status) ->
  console.log "A member could NOT subscribe - error code: " + status
  return


$(document).ready ->
  $('#request-status').hide()

  $('#request-btn').click (e) ->
    e.preventDefault()
    selected_cookie = $('#cookie_drop_down option:selected').text()

    if presenceChannel.members.count >= quota
      $('#request-status').html """
        You’re in a queue &
        will get your cookie when it’s your turn.
        """

      me = presenceChannel.members.me
      me.info = selected_cookie
    else
      $('#request-status').html "Enjoy your " + selected_cookie + " cookie"

    $('#request-status').show()
    return
  return
