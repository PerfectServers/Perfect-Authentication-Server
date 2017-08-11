# Perfect Authentication Server

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat" alt="Swift 3.1">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

## Perfect Authentication Server

This project is a complete authentication solution including local authentication and account creation. It can also function as a OAuth2 Application provider, as well as an OAuth2 client.

It includes ready-to-go Local Authentication routes and setup with sessions, using PostgreSQL as a backend.

A demonstration front-end is set up at [https://auth.perfect.org](https://auth.perfect.org).

There is a [companion iOS application](https://github.com/PerfectExamples/Authentication-iOS-Demo) intended to provide a template for operation with Perfect Local and OAuth2 systems.

All you need to do is complete the information in the `/config/ApplicationConfiguration.json` files with your own information and run. An additional Linux configuration option is supplied for deployment to a production server.

This system is not designed to be integrated with Turnstile. Turnstile support is being deprecated due to this third-party library containing bugs beyond the control of the Perfect project.

## Compatibility with Swift

The master branch of this project currently compiles with **Xcode 8.3** or the **Swift 3.1** toolchain on Ubuntu.

## Configuration

Before running, rename the "ApplicationConfiguration_template.json" file to "ApplicationConfiguration.json". 

Please take care that the JSON is valid. If you change the structure, or remove required commas, this file will not be readable by the application and the application will not run.

### Database configuration

Open this file, and enter the correct details for the database connection:

```
"postgresdbname": "yourdatabase",
"postgreshost": "localhost",
"postgresport": 5432,
"postgresuser": "perfect",
"postgrespwd": "perfect",
```

Note that you will need to create the database, and configure your users' access to this database.

### Mail server access

You must also enter details for the SMTP server, so that users can get verification emails when they register.

```
"mailserver": "smtp://...",
"mailuser": "...",
"mailpass": "...",
"mailfromaddress": "...",
"mailfromname": "...",
```

Please note that there are additional steps required for some mail systems and accounts such as Gmail to accept SMTP connections.

### OAuth2 Client configuration

Each OAuth2 client login you wish to use will require an ID and Secret, as well as adding the appropriate endpoints as authorized Callback URL's. This section has each provider defined with a JSON key - it is your responsibility to obtain and enter these values.

For example, Facebook's configuration section:

```
"facebookAppID": "",
"facebookSecret": "",
"facebookEndpointAfterAuth": "http://localhost:8181/auth/response/facebook",
"facebookRedirectAfterAuth":"http://localhost:8181/oauth/convert",
```

## Building & Running

The following will clone and build an empty starter project and launch the server on port 8181.

```
git clone https://github.com/PerfectServers/Perfect-Authentication-Server.git
cd Perfect-Authentication-Server
swift build
.build/debug/PerfectAuthServer
```

You should see the following output:

```
[INFO] Running setup: account
[INFO] Running setup: application
[INFO] Running setup: accesstoken
[INFO] Running setup: oauth2codes
[INFO] Running setup: config
[INFO] Starting HTTP server mainServer on 0.0.0.0:8181
```

This means the server is running and waiting for connections. Access [http://localhost:8181/](http://localhost:8181/) to see the greeting. Hit control-c to terminate the server.

### Running from Xcode

When running from within Xcode please make sure you have selected the Executable scheme, and "My Mac" from the target dropdown.

Once that has been selected, select "Edit Scheme", and for "Run", select "Options" and check the "Use Custom Working Directory", and choose the project directory from the file browser. This makes sure the Mustache templates and other static files can be found and used.

## Modifying the user interface

The user interface is entirely generated via the content in the `webroot` directory. Inside this directory, all Mustache templates are in `views`, and all CSS, JavaScript and Fonts reside within the `assets` directory.

The system's open source license allows you to modify any part of the project for your own use, however attribution is greatly appreciated.

## Routes

All JSON routes are defined in `/configuration/Routes.swift`, and are namespaced using the /api/v1 routing namespace.

``` swift
routes.append(["method":"get", "uri":"/api/v1/session", "handler":LocalAuthJSONHandlers.session])
routes.append(["method":"get", "uri":"/api/v1/me", "handler":LocalAuthJSONHandlers.me])
routes.append(["method":"get", "uri":"/api/v1/logout", "handler":LocalAuthJSONHandlers.logout])
routes.append(["method":"post", "uri":"/api/v1/register", "handler":LocalAuthJSONHandlers.register])
routes.append(["method":"post", "uri":"/api/v1/login", "handler":LocalAuthJSONHandlers.login])
routes.append(["method":"post", "uri":"/api/v1/changepassword", "handler":LocalAuthJSONHandlers.changePassword])
```

Note that before any of the JSON routes apart from "/api/v1/session" are requested, a Session ID and CSRF token must be obtained from "/api/v1/session".

The response will be similar to this:

``` json
{
    "sessionid": "FCC735A5-5369-4342-9B37-8C9AB163902F",
    "csrf": "F07BC603-19B0-46E5-8BC2-F0A88589D762"
}
```

Each JSON request should have four headers added: `Authorization`, `x-csrf-token`, `Origin`, and `Content-Type`.

Systems such as jQuery and Alamofire will usually add `Origin` and `Content-Type`, however you will need to specifically add `Authorization` and CSRF headers.

The `Authorization` header will use the `sessionid` value from the session route, prepended by "Bearer ". The full string would look like: `Bearer FCC735A5-5369-4342-9B37-8C9AB163902F `.

The `x-csrf-token` header value is taken from the `csrf` value from the session route.


## Issues

We use JIRA for all bugs and support related issues.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

Alternatively, talk with the community directly on the Perfect Slack channel. Join us at http://www.perfect.ly

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)



## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
