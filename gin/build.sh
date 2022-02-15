#

go build -o gormapp gorm/main.go
go build -o xormapp xorm/main.go

rm -rf /tmp/test.sock

# GIN_MODE=release ./gormapp
