# FSP server container
Homepage of FSP: https://fsp.sourceforge.net/  
FSP repository: https://sourceforge.net/p/fsp/code/ci/master/tree/

## Build the container
To build the container, run the `buildah.sh` script. You must have `buildah` installed.

## FSP configuration
An example configuration file, `fspd.conf`, is provided. It is commented to expplain the configuration parameters.

### MTU size
If you want to run the FSP server to serve files to a Nintendo GameCube running Swiss, note that Swiss supports MTU sizes in the [range of 576 to 2030 bytes](https://github.com/emukidid/swiss-gc/blob/ddce2040adc3f6b7f5834e1787b47840e13b652c/cube/swiss/source/devices/fsp/deviceHandler-FSP.c#L216C63-L216C72).

Overhead:

 - IPv4 overhead: 20 bytes.
 - UDP overhead: 8 bytes.
 - [FSP overhead: 12 bytes.](https://github.com/emukidid/swiss-gc/blob/ddce2040adc3f6b7f5834e1787b47840e13b652c/cube/swiss/source/devices/fsp/fsplib.h#L49)

Based on these valued:

 - Standard Ethernet MTU: `1500 - 40 = 1460 bytes`
 - Jumbo frame MTU: `2030 - 40 = 1990 bytes` (If supported by the server)

## Example quadlet file
This example uses a privileged container with a unique user namespace (UserNS=auto). For context, see this [Podman discussion](https://github.com/containers/podman/discussions/13728 )

Be sure to replace `PATH_TO_CONF_FILE` and `PATH_TO_SHARED_DIR` with your actual file paths.

```
[Unit]
Description=FSP server

[Container]
Image=localhost/fsp-server
AutoUpdate=registry
PublishPort=8021:21/udp
UserNS=auto
Mount=type=bind,source=PATH_TO_CONF_FILE,destination=:/etc/fspd.conf,ro=true
Mount=type=bind,source=PATH_TO_SHARED_DIR,destination=/var/ftp

[Service]
# Inform systemd of additional exit status
SuccessExitStatus=0 143

[Install]
WantedBy=default.target
```