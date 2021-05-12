# House News Wire

HouseNewsWire is meant to be a starting point for building your own webapp.  It is a fully functional webapp that supports user registration, login.  It has a simple dashboard with one to many message posting and per-user mark-as-read feature.

The creation process is detailed [in this blog post](https://modfoss.com/building-house-new-wire.html) so that one could follow that guide and arrive at having written the same application.  The repository created in that documentation is available [on GitHub @ symkat/HouseNewsWire](https://github.com/symkat/HouseNewsWire/).

You can try out the application at [House News Wire](https://housenewswire.com/).

## Running With Docker

This docker-compose.yml file will start HouseNewsWire and it will be accessable at [http://127.0.0.1:5000](http://127.0.0.1:5000).

```yaml
version: '3'

services:
  website:
    image: symkat/housenewswire:latest
    container_name: hnw-web
    ports:
        - 5000:5000
  database:
    image: postgres:11
    container_name: hnw-db
    environment:
      - POSTGRES_PASSWORD=housenewswire
      - POSTGRES_USER=housenewswire
      - POSTGRES_DB=housenewswire
    volumes:
      - ./schema.sql:/docker-entrypoint-initdb.d/000_schema.sql:ro
      - database:/var/lib/postgresql/data

volumes:
  database:
```

Make sure to bring in the schema.sql file to the same directory as the `docker-compose.yaml` file.

```bash
curl -Lo schema.sql https://raw.githubusercontent.com/symkat/HouseNewsWire/master/Database/etc/schema.sql
```

Once these files exist, you should be able to start HouseNewsWire with `docker-compose`:

```bash
symkat@test:~/hnw$ ls
docker-compose.yml  schema.sql
symkat@test:~/hnw$ docker-compose up
symkat@test:~/hnw$ docker-compose up
Starting hnw-db  ... done
Starting hnw-web ... done
Attaching to hnw-db, hnw-web
hnw-db      | 
hnw-db      | PostgreSQL Database directory appears to contain a database; Skipping initialization
```

## Forking and Development Environment

Before you begin you should have an environment that supports development.  [modFoss Devel](https://github.com/symkat/modfoss_devel) includes the configuration I use for Debian 10 machines, and installs dependencies that are needed by the build processes for this project.

Once a development environment exists, you'll want to fork the repo.

```bash
symkat@test:~$ git clone git@github.com:symkat/HouseNewsWire.git
Cloning into 'HouseNewsWire'...
...
Resolving deltas: 100% (25/25), done.
symkat@test:~$ cd HouseNewsWire/
```

Once forked, install the modules you'll use to control the development environment.  This will take a couple of minutes, on a 2GiB Linode machine it took about 10 minutes.

```bash
symkat@test:~/HouseNewsWire$ cpanm App::plx App::opan Carton Dist::Zilla
...
Building and testing Dist-Zilla-6.017 ... OK
Successfully installed Dist-Zilla-6.017
140 distributions installed
```

Once these modules are installed, you can build the `HouseNewsWire::DB` package.

```bash
symkat@test:~/HouseNewsWire/Database$ dzil build
[DZ] beginning to build HouseNewsWire-DB
[DZ] writing HouseNewsWire-DB in HouseNewsWire-DB-0.001
[DZ] building archive with Archive::Tar; install Archive::Tar::Wrapper 0.15 or newer for improved speed
[DZ] writing archive to HouseNewsWire-DB-0.001.tar.gz
[DZ] built in HouseNewsWire-DB-0.001
symkat@test:~/HouseNewsWire/Database$ 
```

This package is now built, so you can set up the Web app itself to use it, and install of the dependencies for the webapp.

```bash
symkat@test:~/HouseNewsWire/Web$ plx --userinit
# plx --bareinit
Resolving perl 'perl' via PATH
# plx --config libspec add 25.perl5.ll perl5
symkat@test:~/HouseNewsWire/Database$ cd ../Web/
symkat@test:~/HouseNewsWire/Web$ plx --init
Resolving perl 'perl' via PATH
symkat@test:~/HouseNewsWire/Web$ plx --config libspec add 00tilde.ll $HOME/perl5
symkat@test:~/HouseNewsWire/Web$ plx --config libspec add 40HNW-DB.ll $HOME/HouseNewsWire/Database/lib
```

What you have just done is, first set up [plx](https://metacpan.org/pod/App::plx) for your user account.  Then you configured `plx` in the `~/HouseNewsWire/Web` directory.  When you use `plx`, it will include libraries from `~/perl5/`, `~/HouseNewsWire/Database/lib`.  It will include, and more modules can be installed to the directories `~/HouseNewsWire/Web/devel` and `~/HouseNewsWire/Web/local`.  The `devel/` directory is used for modules that help you develop, while the `local/` directory is for modules that the application is using.

Now it's time to install all of the dependancies.  The first three commands use [opan](https://metacpan.org/pod/App::opan) to set up `HouseNewsWire::DB` as a module that can be included in automatic installation with carton and other tools that interact with cpan.  The last `plx` command installs all of the packages that HouseNewsWire::Web depends on and takes about 10 minutes to run on a 2GiB machine.  Finally, you'll want to install [dex](https://github.com/symkat/App-Dex) to use the commands defined in the directory.

```bash
symkat@test:~/HouseNewsWire/Web$ plx opan init
symkat@test:~/HouseNewsWire/Web$ plx opan add ../Database/HouseNewsWire-DB-0.001.tar.gz 
symkat@test:~/HouseNewsWire/Web$ plx opan merge
symkat@test:~/HouseNewsWire/Web$ plx opan carton install
Web application available at http://localhost:44211/
Installing modules using /home/symkat/HouseNewsWire/Web/cpanfile
Successfully installed Module-Build-0.4231
Successfully installed Module-Runtime-0.016
...
symkat@test:~/HouseNewsWire/Web$ curl --create-dirs -Lo ~/bin/dex https://raw.githubusercontent.com/symkat/App-Dex/master/scripts/dex
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  635k  100  635k    0     0  8471k      0 --:--:-- --:--:-- --:--:-- 8471k
symkat@test:~/HouseNewsWire/Web$ chmod u+x ~/bin/dex 
symkat@test:~/HouseNewsWire/Web$ . ~/.profile
```

Now it's time to run it all.  You'll want to bring up two more terminals.  One to run the database from and one to run the webapp from.

```bash
symkat@test:~$ cd HouseNewsWire/
symkat@test:~/HouseNewsWire$ dex
db                      : Control Devel DB Only
    start                   : Start devel db on localhost via docker.
    stop                    : Stop devel db on localhost via docker.
    status                  : Show status of devel db.
    reset                   : Wipe devel db data.
docker                  : Run Docker Container Environment (Web + DB)
    start                   : Start Docker Container Environment
    stop                    : Stop Docker Container Environment
    status                  : Show status of Docker Container Environment
    reset                   : Wipe data from Docker Container Environment
build                   : Build HouseNewsWire container
symkat@test:~/HouseNewsWire$ dex db start
Creating network "database_default" with the default driver
Creating volume "database_database" with default driver
Pulling database (postgres:11)...
11: Pulling from library/postgres
62deabe7a6db: Pull complete
...
housenewswire-database | 2021-04-30 17:21:20.647 UTC [1] LOG:  database system is ready to accept connections
```

The database is now running in that terminal.  In another terminal you'll want to run the webapp itself.

```bash
symkat@test:~/HouseNewsWire/Web$ plx starman
2021/04/30-17:22:11 Starman::Server (type Net::Server::PreFork) starting! pid(4088)
Resolved [*]:5000 to [0.0.0.0]:5000, IPv4
Binding to TCP port 5000 on host 0.0.0.0 with IPv4
...
[info] HouseNewsWire::Web powered by Catalyst 5.90128
```

Now you should be able to go to your http://Your-IP:5000/register to create an account and have it saved in the database.  You can now work on the code directly and restart it to have changes appear in your web browser.



