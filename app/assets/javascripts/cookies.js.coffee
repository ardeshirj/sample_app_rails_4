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
  console.log "New member SUBSCRIBED!"
  if presenceChannel.members.count >= quota
    $('#request-status').html """
      You’re in a queue &
      will get your cookie when it’s your turn.
      """
    $('#request-status').show()
  else
    $('#request-btn').show()
  return

presenceChannel.bind 'pusher:member_added', (member) ->
  console.log "New member ADDED"
  return

presenceChannel.bind 'pusher:member_removed', (member) ->
  console.log "A member REMOVED!"

  members = presenceChannel.members
  users = members["members"]

  if members.count == quota - 1 # A spot is open now!
    sorted_users = sorted_login_users(users)

    # First person in-line after meeting the quota
    next_user = sorted_users[members.count - 1]

    if members.me.id == parseInt(next_user[0])
      selected_cookie = $('#cookie_drop_down option:selected').text()
      $('#request-status').html "Your " + selected_cookie + " cookie is READY!"
      console.log next_user
  return

presenceChannel.bind 'pusher:subscription_error', (status) ->
  $('#request-status').html """
    We can't serve cookie at the moment.
    Please check back later.
    """
  $('#request-status').show()
  console.log "Error code: " + status
  return


sorted_login_users = (users) ->
  # [[id_value, login_time_value], ...]
  sorted_login_time = []
  for user_id of users
    sorted_login_time.push [
      user_id
      users[user_id].login_time
    ]

  sorted_login_time.sort (a, b) -> a.login_time > b.login_time
  return sorted_login_time

$(document).ready ->
  $('#request-status').hide()
  $('#request-btn').hide()

  $('#request-btn').click (e) ->
    e.preventDefault()
    selected_cookie = $('#cookie_drop_down option:selected').text()
    $('#request-status').html "Enjoy your " + selected_cookie + " cookie"
    $('#request-status').show()
    return
  return
