# Queue 4 Cookies
An small widget on homepage to give cookie to less than 100 user at a time.

Check me out here: https://morning-gorge-17028.herokuapp.com/

## How it works
Once the user login to the website, it will redirected to the homepage, and that is where the cookies live :)

At this point, the Pusher service has triggered the authentication process by sending the `JSON` request to /auth route in `cookies_controller`. The controller will use `devise` helper method called `current_user` to make sure the user is authenticated. After that, It will create and send the `member` information (including login-time) to the Pusher service. The response to that is a `JSON` which include the `auth` value.

This was initial step for the Pusher to subscribe the user to the `presence-cookies-channel` channel. Once the subscription was successful, the `subscription_succeeded` method will be triggered. At this point, we use the channel property called `members.count` to check if we have met the quota yet. If so then we will disable the user `request` button and update the status that user has to wait. Otherwise we just let the user to request a cookie.

Once a user leave the channel then the `member_removed` event will be triggered, and if the number of members is less than the `quota-1` then we know there is an open spot for the next person to get a cookie. At this point, we use the `logged-in` attribute to sort the members in ascending order. This way, we know the `members.count-1` spot is actually the first person in queue line. Now that we know the next person `id` and if it matches with `members.me.id` attribute in channel then we can let them have the selected cookie.
