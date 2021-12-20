# Build
FROM golang:1.17-alpine AS builder

WORKDIR /app

ARG GO_MODULES_USER
ARG GO_MODULES_PERSONAL_ACCESS_TOKEN
ARG GO_PRIVATE_DOMAIN
#ARG GO_PRIVATE_PATH

# alpine does not include git
RUN apk add --no-cache git
RUN git config --global url."https://$GO_MODULES_USER:$GO_MODULES_PERSONAL_ACCESS_TOKEN@$GO_PRIVATE_DOMAIN".insteadOf "https://$GO_PRIVATE_DOMAIN"
#RUN go env -w GOPRIVATE=$GOPRIVATE_PATH

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o ./build/go-package

## Deploy
FROM alpine:3.14.0

WORKDIR /app

RUN apk add curl

COPY --from=builder /app/build /app

CMD ./go-package

