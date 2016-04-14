# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Pusher.log = (message) ->
  console.log message
  return

quota = 3

pusher = new Pusher('885cb9dcf5e442cbfe46',
  authEndpoint: '/auth'
  auth: headers: 'X-CSRF-Token': '<%= form_authenticity_token %>')
presenceChannel = pusher.subscribe('presence-cookies-channel')

presenceChannel.bind 'pusher:subscription_succeeded', (members) ->
  console.log "There are " + members.count + " in this channel"
  return

presenceChannel.bind 'pusher:member_added', (member) ->
  console.log presenceChannel.members
  return

presenceChannel.bind 'pusher:member_removed', (member) ->
  members = presenceChannel.members

  me = members.me
  users = members["members"]
  next_user = earliest_login_user(users)
  # console.log "I am next" if me.id == parseInt(next_user[0])

  if members.count < quota and me.id == parseInt(next_user[0])
    $('#request-status').html "Your " + me.info + " cookie is READY!"
    return
  return

presenceChannel.bind 'pusher:subscription_error', (status) ->
  $('#request-status').html """
    We can't serve cookie at the moment.
    Please check back later.
    """
  $('#request-status').show()  
  console.log "Error code: " + status
  return


earliest_login_user = (users) ->
  # [[id_value, login_time_value], ...]
  sorted_login_time = []
  for user_id of users
    sorted_login_time.push [
      user_id
      users[user_id].login_time
    ]

  sorted_login_time.sort (a, b) -> a.login_time > b.login_time
  return sorted_login_time[0]

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
