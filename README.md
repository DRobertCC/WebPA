# MandalaApartmans

## Dynamic webapp with Servlets, Postgre SQL and AJAX technologies.

Summary

There is an apartman house with 3 apartmans to rent. Users can book one or more apartman(s) per booking, for one or more places for one or more nights but only if there are enough free apartmans for that date interval.

## `DataSource`

Before deploying to a webserver create a `Resource` in the webserver's config (e.g. for Apache Tomcat in `conf/context.xml`).

```
<Resource name="jdbc/mandalaapartmans"
          type="javax.sql.DataSource"
          username="postgres"
          password="admin"
          driverClassName="org.postgresql.Driver"
          url="jdbc:postgresql://localhost:5432/MandalaApartmans"
          closeMethod="close"/>
```
