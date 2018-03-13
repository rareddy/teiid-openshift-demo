#!/usr/bin/sh

oc delete deploymentconfigs teiid-openshift-demo
oc delete buildconfig teiid-openshift-demo-s2i
oc delete route teiid-openshift-demo-odata
oc delete service teiid-openshift-demo-odata
oc delete service teiid-openshift-demo-jdbc
oc delete is teiid-openshift-demo
oc delete secret pg-secret
