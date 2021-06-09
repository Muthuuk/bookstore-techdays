# Azure Bookstore

This is a simple Maven project that builds a standalone JAR which contains a Jetty webserver and a simple bookstore servlet. The application is able
to be built into a container and then available to be deployed as an Azure Web App.

![bookstore](https://user-images.githubusercontent.com/681306/114581130-5e2d4b00-9c77-11eb-837b-4efaefa29e39.png)


The Workflow files in this repository provide the following features:

* Pull Requests code is built and tested using Maven and a Docker container published
* Code QL scanning performed on each push
* Each time a container is built, scanning of the containers will be performed and reported back in the secutiry findings
* Ability to deploy from a PR into `review` environment using labels:
    - `deploy to test`
    - `deploy to qa`
    - `deploy to staging`
* Azure review environments are destroyed once PR is closed (using Ansible triggered from deployment transitions)
* Any commit to the default branch `main` will result in the `prod` Azure web application being updated to the latest code (Continuous Delivery)

For a step-by-step guide see: [Bookstore Demo](https://github.com/github/solutions-engineering/blob/master/guides/demo/end-to-end-demos/bookstore-demo.md)


## Running the Web Application locally

You can run the web application locally using Maven for development purposes, which can be done either directly if you
have Maven and a JDK installed, or inside a container that has Maven and JDK installed.


### GitHub Codespaces

This repository is configured with GitHub Codespaces to make it easy to start with a development environment fully configured.

The container used for the development environment is available from https://github.com/octodemo/container-java-development and is publically available.
There are multiple versions of this, all with the tags providing a specific combination of tools for various cloud vendors. By default you will get a
container with:
* Maven 3.6.3 or later
* JDK 11
* Azure CLI tools


### Running locally:
To build the software run the following command:

```bash
$ mvn package
```

This will generate a jar file at `target/bookstore-v2-1.0.0-SNAPSHOT.jar` directory that when run with the command `java -jar target/bookstore-v2-1.0.0-SNAPSHOT.jar` will run the jetty web server.
The logs from the jar file should report the url to access the web server on, which is port `8080` by default.


### Running in a Docker container:

The Codespace is configured to build and execute the container as a tasks.

* `docker: build container` will build the java project and then the container for you, prompting for details along the way
* `docker: run container` will allow you to run the container that you built allowing you to select the port that is bound to (`8080` by default).

Building and running the container locally without the tasks in GitHub Codespaces can be done using the following;

* `mvn package`
* `docker build . --build-arg VERSION=1.0.0-SNAPSHOT --tag bookstore-v2:latest` (update to the correct version that mvn package will build for you)
* `docker run -p 8080:8080 bookstore-v2:latest` to execute the container and bind to port `8080` to serve requests from
