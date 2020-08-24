## Native psql vs Dockerized psql in PowerShell

### Dockerized psql

Pro

- Super easy if you already use Docker - no other setup needed

Con

- `psql` is running in a Linux shell so you lose all of the PowerShell niceties (`ctrl+c`, `ctrl+v`, `esc`, etc)

### Native psql

Pro

- Native PowerShell keyboard functionality

Con

- Potentially extra setup step (get Postgres)

## Getting native psql

- [Installer](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
- [Binaries only](https://www.enterprisedb.com/download-postgresql-binaries)
  1. Download desired version (latest is probably fine)
  1. Unzip and add to `PATH` (or update and run the following)
     ```powershell
     $archivePath = C:\path\to\download.zip
     $destinationFolder = C:\destination\folder
     Expand-Archive $archivePath $destinationFolder
     [Environment]::SetEnvironmentVariable("Path", (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\").GetValue("Path", "", "DoNotExpandEnvironmentNames") + ";$destinationFolder\pgsql\bin", "Machine")
     ```
- [Scoop](https://scoop.sh/)
  ```powershell
  scoop install postgresql
  ```
