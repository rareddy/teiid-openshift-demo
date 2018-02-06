# teiid-openshift-demo
Teiid OpenShift based Demo Project based on WilFly Swarm

When using Fabric8 Maven Plugin, you can do following tasks in secquence to do the deploy of the VDB
* Start your OpenShift or Minishift
* Log into OpenShift using "oc login host:port"
* Place the -vdb.xml in the "src/main/vdb" folder.
* Create "deployment.yml" in the "src/main/fabric8" folder. This will contain all the properties to create the data sources. Note that you need to create the necessary datasources before and gather the required "secret" names and property names.
* The create "route.yml" and "service.yml" for each of JDBC and OData
* Add any jdbc drivers or resource-adapters based the VDB you are deploying to the pom.xml. For ex: to enable support for MongoDB, you would add

````
    <dependency>
      <groupId>org.wildfly.swarm</groupId>
      <artifactId>teiid-mongodb</artifactId>
    </dependency>
````

* If you are enabling OData then add
````
    <dependency>
      <groupId>org.wildfly.swarm</groupId>
      <artifactId>odata</artifactId>
    </dependency>
````
* Execute "mvn clean fabric8:deploy -Popenshift"

The above will deploy custom Teiid image to the OpenShift
