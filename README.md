# Elm project

## Getting started

You need to have [Elm](https://elm-lang.org/) 0.18 installed on your machine.
You also need [Docker](https://docker.com/)


First start horizon and rethink
```bash
$ docker-compose up
```

Then open another window and start up 
```bash
$ elm-live src/*.elm --output dist/app.js --dir=./dist/
```

Then view it:

    open http://localhost:8181


## Ideas
 - use http://package.elm-lang.org/packages/sanichi/elm-md5/latest to create md5 and
   pull gravatar images of email adresses.
 - unique userNames, don't connect if already a horizon-user
 - sorting, filtering, deleteing etc
 - check if user already in database, then log in with last known name?
