# Minecraft Relay Server (mcrelay)

A minecraft reverse proxy server with server address rewrite.

Supports Minecraft Servers and Clients with version 12w04a or later. (Basically means release 1.2.1 and later.)

Minecraft Versions before 12w04a are **NOT SUPPORTED**!

## Features
* Support reverse proxy for Minecraft servers by server address in the handshake packet which client send to.
* Support rewrite server address and server port to camouflage connection which using official server address. (eg: pretend to be a normal connection to Hypixel, avoiding their server address check.)
* Support IP forwarding using HAProxy's Proxy Protocol. (But refuses any incoming connection using this protocol.)

## Requirements
* Linux
* libresolv.so (usually pre-installed)
* libcjson.so (on debian-like systems, contained in package "libcjson1")

## Compatibility
**Due to Minecraft Handshake restrictions, this server supports:**

* Game relay on server & client with version 12w04a and later, except version 12w17a, 13w41a and 13w41b.
* MOTD relay / MOTD status notice on server & client with version 1.6.1 and later, except version 13w41a and 13w41b.

## Files
* CMakeLists.txt: CMake configuration for compiling
* doc: Folder of documents
* doc/loglevel.info: Definations of log levels
* doc/versions.json: Version manifest
* examples: File templates
* examples/config: Folder of example configurations
* examples/systemd: Folder of example systemd service files
* src: Folder of source codes

## Compile
Before compiling, you need to install cJSON at first.

For example, you can install it on a debian-like systems by <code>apt install libcjson-dev</code>.

Then you can use CMake to compile it, by following:
<pre>
mkdir build
cd build
cmake ..
make
</pre>
Additionally, if you want cross compiling, following CMake properties will helpful:
* <code>-DCMAKE_C_COMPILER</code>: Specify an alternative compiler, CMake using <code>cc</code> by default.
* <code>-DEXEC_SUFFIX</code>: Add a suffix to the final binary file, the file will generated called <code>mcrelay</code>.

## Usage
<pre>
mcrelay < arguments | config_file >
</pre>

The program will run as a non-exit-style program by default.

When using "-f" or "--forking" option, the program will become daemonized, and store its main process' PID into /tmp/mcrelay.pid.

## Config
See "examples/config/config.json" for instructions.

## Instruction of using a DNS-based redirection (SRV)
If you are using a SRV record to provide your service, you should follow the instructions below.

Otherwise, your user will see the message of using a wrong address to connect.

For example, your SRV record should be like this:
<pre>
_minecraft._tcp.srvrecord.example.com. => PRIVORITY WEIGHT PORT host.example.com
</pre>
If you provide "srvrecord.example.com" to your user, you should set your vhostname in the configuration file as follow:
* For most Minecraft versions, use "host.example.com".
* For Minecraft version from 21w20a to 1.17, use "srvrecord.example.com".

For compatibility, it's recommended to add both of them to your configuration.

## IP Forwarding
You can provide the real client address and port through HAProxy's Proxy Protocol by this feature.

It's compatible with any server which support this protocol. (e.g. Bungeecord)

### Bungeecord
To use this feature correctly, turn on the "proxy_protocol" in the "config.yml". ("false" to "true")

## Deploy to Railway
This repository includes a Docker deployment path for Railway with environment-based runtime config generation.

### Files used for Railway
* Dockerfile
* deploy/railway/entrypoint.sh
* .dockerignore

### Required Railway variables
* TARGET_HOST: Hostname of the real upstream server. Example: mc.yourserver.net
* TARGET_PORT: The port number eg. 25565
* VHOSTS: Comma-separated allowed incoming hostnames (Make sure to add the railway tcp endpoint hostname here, and any other hostname you're connecting with)

### Optional Railway variables
* TARGET_PORT: Upstream port. Default: 25565
* VHOSTS: Comma-separated allowed incoming hostnames. Default: TARGET_HOST
* PORT: Railway service port; automatically provided by Railway in most setups
* LISTEN_PORT: Used only when PORT is not set. Default: 25565
* LISTEN_ADDRESS: Default: 0.0.0.0
* NET_PROTOCOL: IPv4 or IPv6. Default: IPv4
* REWRITE: true or false. Default: true
* PHEADER: true or false. Default: false
* LOG_LEVEL: Default: 2

### Railway setup steps
1. Push this repository to GitHub.
2. In Railway, create a new project from that GitHub repository.
3. Railway will detect Dockerfile and build automatically.
4. Set TARGET_HOST to your upstream server hostname.
5. Set VHOSTS to the hostnames clients will use, for example: stevegaming.sdlf.fun
6. Redeploy.
7. Open the generated TCP endpoint in Railway and connect your Minecraft client to that host and port.
