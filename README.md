# psqlx

A wrapper around `psql` that makes interacting with `psql` and your `.pgpass` files easier.

Without `psqlx` your command might look something like this
```
psql -h staging-db.awesome-app.com -p 5433 -d awesome-app -U awesome-app-username
<manually input password>
```

With `psqlx` you don't have to copy/paste all of those values (which can get quite long)
```
psqlx awesome-app stage
```

## Prerequisites
psql (make sure the binary is in your `PATH`)

OR

Docker

## Setup

### PowerShell
1. Clone
2. Update your chosen prerequisite and the path below and add these lines to your `$profile`
   - 💡 Open your profile with `notepad $profile` from PowerShell if you are new to this
	```
	$psqlxRunner = "docker" # or "psql"
	. C:\path\to\cloned\repo\psqlx.ps1
	```
3. Add one or more `<project-name>.pgpass` files to your user directory (`C:\Users\<you>`). See the section below for information about our extended `.pgpass` format.

### Bash
We encourage you to submit a PR if you are interested in a Bash implementation.

## Usage
Format: `psqlx <project-name> <environment>`

Example: `psqlx awesome-app stage`

## .pgpass Files

`psqlx` extends the standard `.pgpass` format with an additional field `environment` so `.pgpass` files intended for use by `psqlx` would have the format
```
hostname:port:database:username:password:environment
```

Specifics of `.pgpass` can be found at https://www.postgresql.org/docs/current/libpq-pgpass.html

A sample `.pgpass` file for use with `psqlx` might be
```
#hostname:port:database:username:password:environment
localhost:5433:awesome-app_integration_tests:postgres::local
staging-db.awesome-app.com:5432:awesome-app:awesome-app-username:my_staging_password:stage
production-db.awesome-app.com:5432:awesome-app:awesome-app-username:my_production_password:prod
```

While standard `.pgpass` files allow wildcards for columns like the port, `psqlx` depends on those columns having actual values in order for it to do its magic.

⚠ Remember to never commit your `.pgpass` file to source control!

## Customization

The `psql` CLI can be customized through `.psqlrc` files. `psqlx` looks for a corresponding `<environment>.psqlrc` in its `psqlrc` folder. We include a few `.psqlrc`s for some standard environments. If a `.psqlrc` cannot be found for the environment identified in your `.pgpass` file, `common.psqlrc` will be loaded instead.