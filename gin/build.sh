#

rm -rf gormapp xormapp

go build -o gormapp gorm/main.go
go build -o xormapp xorm/main.go
