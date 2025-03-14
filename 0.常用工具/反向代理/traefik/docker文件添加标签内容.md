```
    labels:
      - traefik.http.routers.XXX.tls=true
      - traefik.http.routers.XXX.tls.certresolver=letsencrypt
      - traefik.http.services.XXX.loadbalancer.server.port=
```
