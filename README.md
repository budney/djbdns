# djbdns

This is a docker image to run a djbdns DNS server for publishing public DNS records on the internet, *OR* a DNS cache, but not both at the same time. You can run multiple containers if you want more than one DNS and/or more than one cache.

This image is a fork of xcsrz/just-tinydns, which did what it says on the tin: just run tinydns. In addition to adding support for dnscache, this image is optimized for small size: the arm image on a Raspberry Pi is under 5MB, versus almost 150MB for the original image, which was mostly taken up with build tools.

#### Notes:

* The `tinydns` service directory is `/srv/tinydns`
* You (probably) want to mount your data file from your host to `/srv/tinydns/root/data`
* Every time the container is run, the DNS data file (data.cdb) is rebuilt
* If you update your DNS data on the host, you can execute `/rebuild.sh` on the container to make the changes take effect:
`docker exec [ CONTAINER NAME OR ID ] /rebuild.sh`

### Basic Usage:

```docker run -v `pwd`/test.dns:/srv/dns/root/data -p 53:53/tcp -p 53:53/udp -e service=tinydns budney/djbdns```
```docker run -p 53:53/tcp -p 53:53/udp -e service=dnscache budney/djbdns```

### Docker Compose:

```
version: "3"
services:
  tinydns:
    image: budney/djbdns
    environment:
      service: tinydns
    volumes:
      - <PATH-TO-DNS-DATA>:/srv/dns/root/data
    ports:
      - <DNS-IP>:53:53/tcp
      - <DNS-IP>:53:53/udp
  dnscache:
    image: budney/djbdns
    environment:
      service: dnscache
    ports:
      - <CACHE-IP>:53:53/tcp
      - <CACHE-IP>:53:53/udp
```

### References

[Data File Format](http://cr.yp.to/djbdns/tinydns-data.html)

[All About djbdns](http://cr.yp.to/djbdns.html)
