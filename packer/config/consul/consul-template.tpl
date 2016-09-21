global
    maxconn {{key_or_default "service/haproxy/maxconn" "5000"}}
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon

defaults
    mode {{key_or_default "service/haproxy/mode" "tcp"}}
    contimeout 5000
    clitimeout 50000
    srvtimeout 50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

listen stats :81
        balance
        mode http
        stats enable
        stats auth me:password

listen tcp-in
    mode tcp
    balance roundrobin
    bind *:80
    {{range $tag, $services := services | byTag}}{{if eq $tag "routed"}}{{range $service := $services}}{{range serv
ice $service.Name}}server {{.Name}}.service {{.Address}}:{{.Port}}
    {{end}}{{end}}{{end}}{{end}}
