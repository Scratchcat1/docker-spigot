## Minecraft server SPIGOT on Ubuntu 20.04 with OpenJDK 11/16/17
*Fork of [nimmis' image](https://github.com/nimmis/docker-spigot)*


**NOW works with Minecraft 1.18**

Java bug on version 1.17 with 1 core add **-e OTHER_JAVA_OPTS=-Djava.util.concurrent.ForkJoinPool.common.parallelism=1** as workaround

This docker image builds and runs the spigot version of minecraft. 

If the spigot.jar is not found in the minecraft directory the system pulls down BuildTool and builds a new spigot.jar from the latest
released minecraft.jar

Each time the container is started the presence of the file /minecraft/spigot.jar, if the file is missing a build of spigot.jar is started.

Differences to nimmis' image:
- Smaller image size by basing off Debian slim (~70 vs 350MB)
- Graceful termination is handled by bash rather than supervisord
- Multi-arch support: x86_64, armv7, arm64

## Why not a precompiled version of spigot is included

Due to legal reasons you can build it yourself but you can't redistribute the finished jar file.

## Starting the container

To run the latest stable version of this docker image run

	docker run -d -p 25565:25565 --stop-timeout 60 -e EULA=true -v $PWD/volumes/minecraft:/minecraft -v $PWD/volumes/java:/usr/lib/jvm --name my_spigot_container scratchcat1/spigot:latest

the parameter

	-e EULA=true

This is because Mojang now requires the end user to access their EULA, located at
https://account.mojang.com/documents/minecraft_eula, before being able to start the server.

the parameter

	-p 25565:25565

specifies on which external port the internal 25565 should be connected, in this case the same.
If you only type -p 25565 it will connect to a random port on the machine.

the parameters

	-v <WHERE_YOU_WANT_TO_SAVE_THE_MINECRAFT_FILES>:/minecraft
	-v <SOME_PLACE_TO_KEEP_JAVA>:/usr/lib/jvm

provide persistence as docker will delete any files in the container once the container is removed.
The minecraft folder stores all minecraft data and built spigot files.
The java folder keeps a copy of java saved so it doesn't need to be downloaded each time the container is recreated.
## Giving the container a name

To make it easier to handle the container you can give it a name instead of the long
number that's normally given to it by adding a

	--name spigot

to the run command to give it the name spigot, then you can start it easier with

	docker start spigot
	docker stop spigot


## Getting access to the console and logs

If you run the image in attached mode you will see all the output from the console but will *not* be able to interact with it.
To get a console you can interact with you need to connect to the tmux terminal inside the container

	docker exec -it <DOCKER CONTAINER NAME> bash
	root@<DOCKER CONTAINER NAME>:/# tmux attach -t mcserver

This brings up a minecraft console. Use standard tmux shortcuts to navigate through the previous output.

To exit type CTRL-B, CTRL-D to exit tmux and then CTRL-D to exit the container console.

## Environmental Variables

#### SPIGOT_VER

Specifies the version of spigot you would like to use.
If you don't specify this parameter it will check the minecraft directory in the container to see if there is a previous compiled version linked. *If so the container will use that version.*

If no version of spigot is linked (like first time) it will always compile the latest version but if you want a specific version you can specify it by adding

	-e SPIGOT_VER=<version>

where <version> is the version you would like to use, to build it with version 1.18 add

	-e SPIGOT_VER=1.18

to the docker run line.

Please check the web page for [BuildTools](https://www.spigotmc.org/wiki/buildtools/#versions) to get the latest information.

#### MC_MAXMEM

Sets the maximum memory to use <size>m for MB or <size>g for GB, defaulting to 1 GB. To set the maximum memory to 2 GB add this environment variable

    -e MC_MAXMEM=2g

#### MC_MINMEM

Sets the initial memory reservation used, use <size>m for MB or <size>g for GB, if this parameter is not set, it is set to MC_MAXMEM. To set the initial size to 512 MB

    -e MC_MINMEM=512m
#### OTHER_JAVA_OPS

Allows adding other Java options when starting minecraft

	-e OTHER_JAVA_OPS=
## Building Spigot

This will take a couple of minutes depending on computer and network speed. It will pull down
the selected version on BuildTools and build a spigot.jar from the selected minecraft version.
This is done in numerous steps so be patient.

The output of this command will look something like this:

	$ sudo docker run -it -e EULA=true -v $PWD/volumes/minecraft:/minecraft -v $PWD/volumes/java:/usr/lib/jvm spigot-docker
	checking latest
	% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									Dload  Upload   Total   Spent    Left  Speed
	100  138k  100  138k    0     0  1040k      0 --:--:-- --:--:-- --:--:-- 1040k
	Setting version to latest
	Detected archtecture is x64
	Downloading JDK 1.17
	% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									Dload  Upload   Total   Spent    Left  Speed
	100  183M  100  183M    0     0  3905k      0  0:00:48  0:00:48 --:--:-- 4135k
	set java version to 17
	<DOWNLOAD BUILD OUTPUT OMITTED>
	Java Version: Java 17
	Current Path: /build-mc/.
	git version 2.30.2
	Git name not set, setting it to default value.
	Git email not set, setting it to default value.
	Picked up _JAVA_OPTIONS: -Djdk.net.URLClassPath.disableClassPathURLCheck=true -Xmx1024M
	openjdk version "17.0.1" 2021-10-19
	OpenJDK Runtime Environment Temurin-17.0.1+12 (build 17.0.1+12)
	OpenJDK 64-Bit Server VM Temurin-17.0.1+12 (build 17.0.1+12, mixed mode, sharing)
	Attempting to build version: 'latest' use --rev <version> to override
	<BUILD OUTPUT OMITTED>



Once the compilation completes the server will start and you will see something like

	Success! Everything completed successfully. Copying final .jar files now.
	Copying spigot-1.18.1-R0.1-SNAPSHOT-bootstrap.jar to /build-mc/./spigot-1.18.1.jar
	- Saved as ./spigot-1.18.1.jar
	Successfull build of spigot version latest
	Setting latest as current spigot version
	start.sh missing, creating link for /minecraft/start.sh
	Server console started in the tmux session.
	Starting server
	Loading libraries, please wait...
	<SERVER OUTPUT>


you can then exit from the log with CTRL-C

## Stopping the container

When the container is stopped by typing stop in the tmux console or with the command

	docker stop spigot

The spigot server is then shutdown nicely with a console stop command to give it time to save everything before
stopping the container. If you look in the output from the server you will see something like

	[21:04:32] [Server thread/INFO]: Time elapsed: 4330 ms
	[21:04:32] [Server thread/INFO]: Done (44.822s)! For help, type "help"
	>
	^CSIGTERM received, stopping the server
	stop
	stop
	[21:05:10] [Server thread/INFO]: Stopping the server
	[21:05:10] [Server thread/INFO]: Stopping server
	[21:05:10] [Server thread/INFO]: Saving players
	[21:05:10] [Server thread/INFO]: Saving worlds
	[21:05:10] [Server thread/INFO]: Saving chunks for level 'ServerLevel[world]'/minecraft:overworld
	[21:05:10] [Server thread/INFO]: Saving chunks for level 'ServerLevel[world_nether]'/minecraft:the_nether
	[21:05:10] [Server thread/INFO]: Saving chunks for level 'ServerLevel[world_the_end]'/minecraft:the_end
	[21:05:10] [Server thread/INFO]: ThreadedAnvilChunkStorage (world): All chunks are saved
	[21:05:10] [Server thread/INFO]: ThreadedAnvilChunkStorage (DIM-1): All chunks are saved
	[21:05:10] [Server thread/INFO]: ThreadedAnvilChunkStorage (DIM1): All chunks are saved
	[21:05:10] [Server thread/INFO]: ThreadedAnvilChunkStorage: All dimensions are saved
	>Server stopped completely

### Problems with external mounted volumes

When a external volume is mounted the UID of the owner of the volume may not match the UID of the minecraft user (1000). This can result in problems with write/read access to the files. 

To address this problem a check is done between UID of the owner of /minecraft and the UID of the user minecraft. If there is a mismatch the UID of the minecraft user is changed to match the UID of the directory.

If you don't want to do this and want to manually set the UID of the minecraft user there is a variable named SPIGOT_UID which defines the minecraft user UID, adding

	-e SPIGOT_UID=1132

sets the minecraft user UID to 1132.


## Building the Docker Image
To build this image for your machine you can simply use the normal docker build command

	docker build -t spigot ./

If you want to build this image for multiple architectures you need to use a slightly different set of commands. However this allows you to push a single image from which clients can automatically select the correct architecture.

First set up a binfmt container which allows other architectures to be emulated

	docker run --privileged --rm tonistiigi/binfmt --install all

Then build the images and push (docker doesn't currently support loading multi-arch images directly)

	docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 --tag scratchcat1/minecraft-spigot:latest --push ./
## Old versions news

- Updated java version to 17 which is a LTS version
- Adopt moved to Eclipe Foundation and changed name to Adoptium
- Updated java version to 16 to compile minecraft 1.17
- Switched to Adopt OpenJDK
- Fix for problem introduced during fall of 2017 for both Windows 10 and MacOS versions of docker, failed to build new versions of spigot 
- Autodetection of timezone if container has access to internet
- adjust minecraft user UID to match mounted volume
- selectable memory size for the Java process
- selectable spigot version
- do a nice shutdown of the server when the docker stop command is issued
- docker accessible commands to 
   - start/stop/restart the spigot server
   - send console commands to the server
   - look at console output from the server

## Issues

If you have any problems with or questions about this image, please contact us by submitting a ticket through a [GitHub issue](https://github.com/Scratchcat1/docker-spigot/issues "GitHub issue")

1. Look to see if someone already filled the bug, if not add a new one.
2. Add a good title and description with the following information.
 - if possible an copy of the output from **cat /etc/BUILDS/*** from inside the container
 - any logs relevant for the problem
 - how the container was started (flags, environment variables, mounted volumes etc)
 - any other information that can be helpful

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

## Future features

- automatic backup
- plugins
- more....

