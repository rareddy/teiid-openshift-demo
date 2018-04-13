# Teiid Openshift Demo

This execute this sample project requires basic knowledge in
* OpenShift
* Teiid
* Maven
* Wildfly-Swarm (preferable not required)

## Introduction
This project serves as an example how to set up a MicroService using Teiid. It shows how to configure and deploy your VDB using Fabric8 Maven Plugin using WildFly-Swarm based Teiid as MicroService in OpenShift. 

This project will show you 
* Build WildFly-Swarm based Teiid (WFST) instance based Maven pom.xml file.
* Configure to deploy a -vdb.xml given into the WFST
* Configure the connection details for your Data Source(s)
* Configure OData route.

## Pre-Requisites
Before you begin, you must have access to OpenShift Dedicated cluster, or `minishift` or `oc cluster up` running and have access the the instance.

* Start your OpenShift or MiniShift.
* Log into OpenShift using on the command line. 
    ```
    $ oc login host:port
    ```
* Using the Service Catalog create all the data sources required by your VDB. For this example we would need a PostgreSQL database. Using the https://host:port/console log into the OpenShift Web Console application.
* Click on Postgresql database icon and create instance of it. Use user name "admin", with password "admin". Keep the database name as "sampledb". Do not need to bind yet.
* Once the Posgresql instance is started and available, now lets populate it with some schema and data information. (At least one table is needed in `PUBLIC` schema within the DB.)
* Goto menu "Applications/Pods" and find "postgres" pod and click on it.
* Click on the "Terminal" tab
* Execute
```
$ psql -U admin -W sampledb
Password for user admin:xxxx
```
$ Now paste your DDL/DML contents into the window. For Example: 
```sql
CREATE TABLE  PRODUCT (
   ID integer,
   SYMBOL varchar(16),
   COMPANY_NAME varchar(256),
   PRIMARY KEY(ID)
);
INSERT INTO PRODUCT (ID,SYMBOL,COMPANY_NAME) VALUES(1002,'BA','The Boeing Company');
INSERT INTO PRODUCT (ID,SYMBOL,COMPANY_NAME) VALUES(1003,'MON','Monsanto Company');
```
Note: There are alternate ways to connect to pod. For example, you can use `oc rsh <pod-name>` and you will be presented with same console as above process. The process of executing `pql` command and DDL/DML after is exactly same. 

## Example
* Make a clone of this project, and edit pom.xml with your name of the project.
* Place the -vdb.xml in the `src/main/vdb` folder. Note that the VDB name MUST match to the ${project.artifactId} and vdb version must match to the ${project.version}.
* Create a file like `pg-secret.yml` file in `src/main/fabric8` folder to define the credentials you set in the above Postgresql database. Note that the values are base64 encoded. You can use command like `echo admin | base64` to encode. Note that different data sources need different types of properties. Consult Teiid documents for required properties.
* Create `deployment.yml` in the `src/main/fabric8` folder. This will contain all the properties to create the data sources. Note that you need to create the necessary datasources before and gather the required "secret" names and property names. Change/add the properties in this file according to your configuration. 
* Edit service and route files accordingly 
* Add any jdbc drivers or resource-adapters based the VDB you are deploying to the pom.xml. For example to enable support for Postgresql, you would add in <dependencies> section the following maven configuration for Postgresql JDBC driver

```xml
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>${version.postgresql}</version>
</dependency>
```

* If you are enabling OData then add

```xml
<dependency>
  <groupId>org.wildfly.swarm</groupId>
  <artifactId>odata</artifactId>
</dependency>
```
* Execute following command to deploy custom Teiid image to the OpenShift.
```
$ mvn clean fabric8:deploy -Popenshift
```

Once the build is completed, go back OpenShift web-console application and make sure you do not have any errors with deployment. Now go to "Applications/Routes" and find the OData endpoint for your service and append  `/odata4/teiid-openshift-demo/accounts/product` to see the PRODUCT table data. For ex: http://teiid-openshift-demo-odata-myproject.192.168.42.70.nip.io/odata4/teiid-openshift-demo/accounts/product

