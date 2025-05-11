# FSP server container
Homepage of FSP: https://fsp.sourceforge.net/  
FSP repository: https://sourceforge.net/p/fsp/code/ci/master/tree/

## How to use it?
Pull the published container:`podman pull ghcr.io/ddund/fsp-server:latest`

Or build the container on your own. Clone the repo, initialize and update the submodule and run the `buildah.sh` script. You must have `buildah` installed.

## FSP configuration
An example configuration file, `fspd.conf`, is provided. It is commented to explain the configuration parameters.

If you use systemd you will need to enable the daemonize command by adding `daemonize on` to your fspd.conf file or commenting it out in the example file.
### MTU size
If you want to run the FSP server to serve files to a Nintendo GameCube running Swiss, note that Swiss supports MTU sizes in the [range of 576 to 2030 bytes](https://github.com/emukidid/swiss-gc/blob/ddce2040adc3f6b7f5834e1787b47840e13b652c/cube/swiss/source/devices/fsp/deviceHandler-FSP.c#L216C63-L216C72).

Overhead:

 - IPv4 overhead: 20 bytes.
 - UDP overhead: 8 bytes.
 - [FSP overhead: 12 bytes.](https://github.com/emukidid/swiss-gc/blob/ddce2040adc3f6b7f5834e1787b47840e13b652c/cube/swiss/source/devices/fsp/fsplib.h#L49)

Based on these valued:

 - Standard Ethernet MTU: `1500 - 40 = 1460 bytes`
 - Jumbo frame MTU: `2030 - 40 = 1990 bytes` (If supported by the server)

## Files
You might also want to add the following empty files to the FSP home directory to enable swiss to read/write:

```
.FSP_OK_ADD
.FSP_OK_DEL
.FSP_OK_MKDIR
.FSP_OK_RENAME
```

Don't forget the `.` before the filename. You can [read more about them here](https://man.freebsd.org/cgi/man.cgi?query=fspd&sektion=1&manpath=freebsd-ports).

## Example quadlet files
If you don't know what Podman Quadlet is you can [read more about them here](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html
). These examples uses a privileged container with a unique user namespace (UserNS=auto). For context, see this [Podman discussion](https://github.com/containers/podman/discussions/13728).


### Standard Ethernet MTU

Be sure to replace `PATH_TO_CONF_FILE` and `PATH_TO_SHARED_DIR` with your actual file paths.

```
[Unit]
Description=FSP server

[Container]
Image=ghcr.io/ddund/fsp-server:latest
AutoUpdate=registry
PublishPort=8021:21/udp
UserNS=auto
Mount=type=bind,source=PATH_TO_CONF_FILE,destination=/etc/fspd.conf,ro=true
Mount=type=bind,source=PATH_TO_SHARED_DIR,destination=/var/ftp

[Service]
# Inform systemd of additional exit status
SuccessExitStatus=0 143

[Install]
WantedBy=default.target
```

### Jumbo frame MTU

You can name this file `fsp-server.network` for example.

```
[Network]
NetworkName=fsp-server
Options=mtu=9000
```

Then the container file will look like this:

```
[Unit]
Description=FSP server

[Container]
Image=ghcr.io/ddund/fsp-server:latest
AutoUpdate=registry
PublishPort=8021:21/udp
UserNS=auto
Network=fsp-server.network
Mount=type=bind,source=PATH_TO_CONF_FILE,destination=/etc/fspd.conf,ro=true
Mount=type=bind,source=PATH_TO_SHARED_DIR,destination=/var/ftp

[Service]
# Inform systemd of additional exit status
SuccessExitStatus=0 143

[Install]
WantedBy=default.target
```