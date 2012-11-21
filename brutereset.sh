#!/bin/bash
mysql cphulkd -uuser -ppass -e "select * from brutes; select * from logins;"
mysql cphulkd -uuser -ppass -e "delete from brutes; delete from logins;"
