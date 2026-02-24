# FLASKPOSTGRES-tmpl

To create a new projecrt, run 

`./setup-dockercompose-project.sh <project_name>`

To provision the new app:

```
cd <project_name>

cp etc/env.sample .env 
cp etc/env.prod.sample .env.prod

```

Make changes to `.env` and `.env.prod`

To start the new app for local dev:

`make dev`

To start on production:

`make prod`

