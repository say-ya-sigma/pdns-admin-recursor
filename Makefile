up:
	@docker compose up -d
build:
	@docker compose build
down:
	@docker compose down
permit:
	@chown -R 100:101 pdns/
log:
	@docker compose logs powerdns
log-admin:
	@docker compose logs dnsadmin
log-recursor:
	@docker compose logs recursor
