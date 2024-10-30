# Etapa de build
FROM golang:alpine AS builder

# Instalar UPX
RUN apk add --no-cache upx

# Definir diretório de trabalho
WORKDIR /usr/src/app

# Copiar arquivos go.mod e go.sum
COPY go.mod  ./

# Baixar dependências
RUN go mod download

# Copiar o código-fonte
COPY . .

# Compilar o binário com otimizações
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

# Comprimir o binário usando UPX
RUN upx --best --lzma -o main_compressed main

# Etapa final
FROM scratch

# Copiar o binário comprimido da etapa de build
COPY --from=builder /usr/src/app/main_compressed /app/main

# Expor a porta 8080
EXPOSE 8080

# Definir ponto de entrada
ENTRYPOINT ["/app/main"]