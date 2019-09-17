function psqlx($Project, $PsqlEnv = "local")
{
  if (@("psql", "docker") -inotcontains $psqlxRunner) {
    throw "`$psqlxRunner must be set before running psqlx. Acceptable values are 'psql' or 'docker'."
  }

  $columns = @{ "hostname" = 0; "port" = 1; "database" = 2; "username" = 3; "password" = 4; "id" = 5 }
  $detailsDelimiter = "(?<!\\):"

  $pgpassFile = "$env:USERPROFILE\$Project.pgpass"
  if (!(Test-Path $pgpassFile)) {
    throw "'$pgpassFile' not found"
  }
  
  $pgpassContent = (Get-Content $pgpassFile)
  $psqlConnectionDetailsLine = $pgpassContent | ? { ($_ -split $detailsDelimiter)[$columns.id] -eq $PsqlEnv }
  if (!$psqlConnectionDetailsLine) {
    throw "No matching connection details for '$PsqlEnv'"
  }

  $psqlrcFile = "$PSScriptRoot\psqlrc\$PsqlEnv.psqlrc"
  if (!(Test-Path $psqlrcFile)) {
    $psqlrcFile = "$PSScriptRoot\psqlrc\common.psqlrc"
  }

  $originalWindowTitle = $Host.UI.RawUI.WindowTitle
  $Host.UI.RawUI.WindowTitle = "$PsqlEnv Postgres"

  $psqlConnectionDetails = $psqlConnectionDetailsLine -split $detailsDelimiter
  $psqlHostname = $psqlConnectionDetails[$columns.hostname]
  $psqlPort = $psqlConnectionDetails[$columns.port]
  $psqlDatabase = $psqlConnectionDetails[$columns.database]
  $psqlUsername = $psqlConnectionDetails[$columns.username]

  Write-Output "Connecting to $psqlHostname as $psqlUsername with $psqlxRunner"

  if ($psqlxRunner -ieq "psql") {
    $env:PSQLRC = $psqlrcFile
    $env:PGPASSFILE = $pgpassFile

    psql -h $psqlHostname -p $psqlPort -d $psqlDatabase -U $psqlUsername -a -v prompt_db_name=$PsqlEnv

    Remove-Item Env:PSQLRC
    Remove-Item Env:PGPASSFILE
  } else {
    $containerPsqlrcFile = "/var/psqlrc/$(Split-Path $psqlrcFile -Leaf)"
    $containerPgpassFile = "/var/$Project.pgpass"

    if (!(docker ps -q -f "name=psqlx")) {
      docker run -d --rm --network=host -e PGPORT=55555 -v "$(Split-Path $psqlrcFile -Parent):/var/psqlrc" --name psqlx postgres > $null
      docker cp $pgpassFile psqlx:/var
      docker exec psqlx chmod 0600 $containerPgpassFile
    }

    docker exec -it -e PSQLRC=$containerPsqlrcFile -e PGPASSFILE=$containerPgpassFile psqlx psql -h $psqlHostname -p $psqlPort -d $psqlDatabase -U $psqlUsername -a -v prompt_db_name=$PsqlEnv

    if (!(docker exec psqlx sh -c "ps -e | grep psql")) {
      docker stop psqlx > $null
    }
  }

  $Host.UI.RawUI.WindowTitle = $originalWindowTitle
}