.DEFAULT_GOAL := help

SOPS_DOTENV := --input-type dotenv --output-type dotenv
SOPS_BINARY := --input-type binary --output-type binary

.PHONY: help up down logs restart decrypt clean edit-env

help:
	@echo "Uso:"
	@echo "  make up        Desencripta secretos y levanta los containers"
	@echo "  make down      Detiene los containers"
	@echo "  make restart   Reinicia los containers"
	@echo "  make logs      Muestra logs"
	@echo "  make decrypt   Solo desencripta sin levantar"
	@echo "  make clean     Elimina archivos desencriptados del disco"
	@echo "  make edit-env  Edita el .env encriptado"

decrypt:
	sops $(SOPS_DOTENV) --decrypt .env.enc > .env
	sops $(SOPS_BINARY) --decrypt secrets/cloudflare_dns_api_token.enc > secrets/cloudflare_dns_api_token
	chmod 600 .env secrets/cloudflare_dns_api_token

up: decrypt
	docker compose up -d
	@$(MAKE) clean

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

clean:
	rm -f .env secrets/cloudflare_dns_api_token

edit-env:
	sops $(SOPS_DOTENV) .env.enc

recreate: decrypt
	docker compose up -d --force-recreate
	@$(MAKE) clean
