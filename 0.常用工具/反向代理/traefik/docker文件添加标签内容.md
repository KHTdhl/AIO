```
    labels:
      - traefik.http.routers.XXX.tls=true
      #将XXX替换为服务名称
      - traefik.http.routers.XXX.tls.certresolver=letsencrypt
      #将XXX替换为服务名称
      - traefik.http.services.XXX.loadbalancer.server.port=000
      #将XXX替换为服务名称，将000替换为服务对应的端口号
    networks:
      - traefik
    logging:
      driver: json-file
      options:
        max-size: 1m
networks:
  traefik:
    external: true
```
