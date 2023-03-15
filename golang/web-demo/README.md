```
go mod init web-demo
go env -w GOPROXY=https://goproxy.cn,direct
go mod tidy
GOARCH=amd64 go build -o web-demo main.go

./web-demo

http://ip/
http://ip/version
```
