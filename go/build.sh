#

rm -rf gormapp xormapp fiberapp

go build -o gormapp gorm/main.go
go build -o xormapp xorm/main.go
go build -o fiberapp fiber/main.go
