# PowerDNS-SQLite with Recursor on Alpine

This project provides a Docker container for PowerDNS with an SQLite backend, running on Alpine Linux, extended to include a PowerDNS Recursor for caching DNS functionality alongside authoritative DNS. The PowerDNS settings are stored in /etc/pdns/pdns.conf, and the SQLite database is located at /pdns/pdns_db.sqlite. The RESTful API is enabled by default. Additionally, a PowerDNS Admin web interface is included for management.

Features

- PowerDNS Authoritative Server: Manages DNS zones with an SQLite backend.
- PowerDNS Recursor: Provides caching DNS resolver functionality.
- PowerDNS Admin: Web-based management interface for PowerDNS.
- Alpine-based: Lightweight and secure Docker image.
- Customizable Configuration: Override PowerDNS settings via a volume-mounted configuration file.
- RESTful API: Enabled by default for programmatic DNS management.

## Docker Compose

```yaml
services:
    powerdns:
        build: .
        ports:
            - 8081:8081
        environment:
            - PDNS_LOG_LEVEL=4
            - PDNS_API_KEY=34H5G34J5H43H34
            - PDNS_WEBSERVER_PASSWORD=123456
            - PDNS_WEBSERVER_ALLOWED_FROM=127.0.0.1,::1,172.0.0.0/8
        volumes:
            - ./pdns/:/pdns/
        networks:
            powerdns:
                ipv4_address: 172.23.0.2
    recursor:
        build:
            context: .
            dockerfile: recursor.dockerfile
        restart: always
        ports:
            - 53:53
            - 53:53/udp
        volumes:
            - ./recursor.conf:/etc/pdns/recursor.conf
        networks:
            powerdns:
                ipv4_address: 172.23.0.3
    dnsadmin:
        image: powerdnsadmin/pda-legacy:latest
        environment:
            - SQLALCHEMY_DATABASE_URI=sqlite:////pdns/pdns_db.sqlite
            - GUINCORN_TIMEOUT=60
            - GUNICORN_WORKERS=2
            - GUNICORN_LOGLEVEL=DEBUG
        volumes:
            - ./pdns/:/pdns/
        ports:
            - 80:80
        logging:
            driver: json-file
            options:
              max-size: 10m

networks:
    powerdns:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: 172.23.0.0/16
                  gateway: 172.23.0.1
```

### Services
1. powerdns  
The PowerDNS authoritative server handles DNS zones with an SQLite backend.
  - Image: Built from the current directory (Dockerfile).
  - Ports:
    - 8081:8081 for RESTful API.
  - Environment Variables:
    - `PDNS_LOG_LEVEL=4`: Log level.
    - `PDNS_API_KEY=34H5G34J5H43H34`: API key for secure API access. Please change it.
    - `PDNS_WEBSERVER_PASSWORD=123456`: Password for the web server. Please change it.
    - `PDNS_WEBSERVER_ALLOWED_FROM=127.0.0.1,::1,172.0.0.0/8`: Restricts web server access to specified IP ranges.

  - Volumes:
    - `./pdns/:/pdns/`: Persists the SQLite database.

  - Network:
    - Assigned IP: `172.23.0.2` on the powerdns network.

2. recursor  
The PowerDNS Recursor provides caching DNS resolver functionality.
  - Image: Built from the current directory using `recursor.dockerfile`.
  - Restart Policy: `always` to ensure the service restarts on failure.
  - Ports: `53:53 (TCP)` and `53:53/udp` for DNS queries.

  - Volumes:
    - `./recursor.conf:/etc/pdns/recursor.conf`: Mounts a custom Recursor configuration file.

  - Network:
    - Assigned IP: `172.23.0.3` on the powerdns network.

3. dnsadmin  
The PowerDNS Admin web interface for managing DNS zones.
  - Image: powerdnsadmin/pda-legacy:latest. This image seems to be Alpine-based with Flask and Gunicorn included.
  - Environment Variables:
    - `SQLALCHEMY_DATABASE_URI`=sqlite:////pdns/pdns_db.sqlite: Connects to the shared SQLite database.
    - `GUINCORN_TIMEOUT=60`: Sets Gunicorn timeout to 60 seconds.
    - `GUNICORN_WORKERS=2`: Configures 2 Gunicorn workers.
    - `GUNICORN_LOGLEVEL=DEBUG`: Enables debug-level logging.

  - Volumes:
    - `./pdns/:/pdns/`: Shares the SQLite database with the powerdns service.

  - Ports:
    - 80:80: Exposes the web interface on port 80.

  - Logging: Uses the json-file driver with a maximum log file size of 10m.


### Network Configuration
  - Network Name: powerdns
    - Driver: bridge
    - IPAM Configuration:
       - Subnet: 172.23.0.0/16
       - Gateway: 172.23.0.1

The powerdns and recursor services have static IP addresses (172.23.0.2 and 172.23.0.3, respectively) for predictable communication within the network.

