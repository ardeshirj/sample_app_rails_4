# Queue 4 Cookies
An small widget on homepage to give cookie to less than 100 user at a time.

## How it works
Once the user login to the website, it will redirected to the homepage, and that is where the cookies live :)

At this point, the Pusher service has triggered the authentication process by sending the `JSON` request to /auth route in CookiesController. The controller will use `devise` helper method called `current_user` to make sure the user is authenticated. After that, It will create and send the `member` information to the Pusher service. The response to that is a `JSON` which include the `auth` value.

This was initial step for the Pusher to subscribe the user to the `presence-cookies-channel` channel. The Pusher will then add the user to `member` property of the channel, and this will happen for every user that login for up 100 users.

Each user can request a favorite cookie, however if we already reached out the `quota` then the user has to wait till some users leave the `cookie` channel. Once a user leave the channel then the`member_removed` event will be triggered, and if the number of members is less than the quota then the user who logged-in earlier will get the cookie.

Please note we use the the user `login-time` to find out who is the next on in the queue to get a cookie. This `login-time` has been created during the `auth` process where we created the users and sent them to the Pusher service.
