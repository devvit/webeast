#

rm -rf gormapp xormapp fiberapp fiber2app

go build -o gormapp gorm/main.go
go build -o xormapp xorm/main.go
go build -o fiberapp fiber/main.go
go build -o fiber2app fiber2/main.go
