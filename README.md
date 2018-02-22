# teiid-openshift-demo
Teiid OpenShift based Demo Project based on WilFly Swarm

## Introduction
This project serves as an example how to quickly set up a microservice using Teiid. It shows how to deploy your VDB using Fabric8 Maven Plugin as a Swarm microservice to OpenShift.
These are necessary steps if you want to use this project as a starting point for your use case. 
* Start your OpenShift or MiniShift.
* Log into OpenShift using
    ```
    $ oc login host:port
    ```
* Place the -vdb.xml in the `src/main/vdb` folder.
* Create `deployment.yml` in the `src/main/fabric8` folder. This will contain all the properties to create the data sources. Note that you need to create the necessary datasources before and gather the required "secret" names and property names.
* The create `route.yml` and `service.yml` for each of JDBC and OData
* Add any jdbc drivers or resource-adapters based the VDB you are deploying to the pom.xml. For example to enable support for MongoDB, you would add
    ```xml
    <dependency>
      <groupId>org.wildfly.swarm</groupId>
      <artifactId>teiid-mongodb</artifactId>
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
* NOTE: If you only need to review the resulting contents to be deployed you can run following command and review contents of the `target` directory.
    ```
    $ mvn clean package -Popenshift
    ```

## Example using PostgreSQL
### Prerequisite
* Running OpenShift or MiniShift instance.
* User is logged in via `oc`.
* NOTE: The project name for this example is `teiid-os-demo`.
### Instructions
* Create a postgresql application:
    ```
    $ oc new-app postgresql -e POSTGRESQL_USER=user \
    -e POSTGRESQL_PASSWORD=password \
    -e POSTGRESQL_DATABASE=komododb
    ```
* Store the credentials as a secret in OpenShift:
  * Create a file `postgresql-secret.yml` with following contents:
    ```yaml
    apiVersion: v1
    metadata:
      name: postgresql
      namespace: teiid-os-demo
    stringData:
      database-name: komododb
      database-password: password
      database-user: user
    kind: Secret
    ```
  * Create the secret in OpenShift:
    ```
    $ oc create -f postgresql-secret.yml
    ```
* Create a table in the PostgreSQL instance. (At least one table is needed in `PUBLIC` schema within the DB.)
    * List your pods and note the postgresql pod:
        ```
        $ oc get pods
        ```
    * Connect to your pod via shell:
        ```
        $ oc rsh <podname>
        ```
    * Via `psql` run following queries:
        ```sql
        CREATE TABLE usr(id integer PRIMARY KEY, name varchar(30));
        INSERT INTO usr(id, name) VALUES (1, 'Jan'), (2, 'Andrej');
        ```
        * NOTE: make sure you connect to your database by providing the name:
            ```
            $ psql -U user -d komododb
            ```
* See `deployment.yml` descriptor placed in `src/main/fabric8` folder to see, how the resulting image is being configured.
    * NOTE: You can use parameters within this file that will be resolved during the maven build. This might come handy if you want to parameterize the jdbc url by various service names. You can create variable `${db.hostname}`:
        ```
        ...
        -Dswarm.datasources.data-sources.MyDS.connection-url=jdbc:postgresql://${db.hostname}:5432/$(DATABASE_NAME)
        ...
        ```
        and provide the value only when running Maven:
        ```
        $ mvn <goal> -Popenshift -Ddb.hostname=postgresql_x_y
        ```
* For a services and routes definitions see `src/main/fabric8` folder.
* Deploy the service into OpenShift:
    ```
    mvn clean fabric8:deploy -Popenshift
    ```
* Check your OpenShift project for a new Deployment.
    * Try accessing odata4 interface. The odata web context will be `/odata4/Portfolio/Accounts/usr`.

