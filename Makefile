buildx86:
	GOARCH=amd64 GOOS=linux  go build -o hello ./x86/main.go
	zip hellox86.zip hello

buildarm64:
	GOARCH=arm64 GOOS=linux go build -o bootstrap ./arm64/main.go
	zip bootstrap.zip bootstrap

clean:
	rm -f ./hello ./hellox86.zip ./bootstrap ./bootstrap.zip