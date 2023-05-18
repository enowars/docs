# Create a new Service

This section covers the necessary steps to create your own service and integrate it with the EnoEngine and bambictf framework. While you are pretty free in most design choices related to your service (as long as you get it working using a single docker-compose file), there are some things to consider especially with regards to the directory structure and the checker development to ensure everything works with the surrounding infrastructure.

## What does a service consist of?

A service consists of:

 - the service
 - the checker
 - (internal) documentation
 - GitHub Actions workflows to check that everyhing is working as expected

## Service Structure

All service repositories must follow a certain structure to ensure the automated deployment will work. There is an example repository to serve as reference here: https://github.com/enowars/enowars-service-example

However, do note that this repository differs in some regards from an actual service repository, for example this repository contains multiple checker-directories to showcase the variety of existing checker libraries. So please do read the following notes carefully and ensure your service matches the structure described here.

There are two directories called `service` and `checker` that are required and must be named and laid out exactly according to the specification.

### Service

There must be a directory called `service` at the top level of your repository. The contents of this directory will be copied onto each vulnbox. **Thus there MUST NOT be any internal documentation containing hints to vulnerabilities/exploits in this directory!**

When it comes to the contents of the directory, you are pretty free in how you layout your directory structure. However, the following conditions must be met:

1. Your service **MUST** be able to be started simply by running `docker-compose up -d` in your `service`-directory. This is exactly what the provisioning process on the vulnbox does, thus it must not require any manual intervention to start the service.
2. You **MAY** create an optional `setup.sh`-script in your `service`-directory that is executed BEFORE running `docker-compose up -d`, if you require any additional setup steps that can not reasonably be executed as part of your docker-compose setup.
3. You **MUST** create a `.env`-in your `service` directory in which you set `COMPOSE_PROJECT_NAME=your_chosen_name_service`, e.g. `COMPOSE_PROJECT_NAME=n0t3b00k_service` if your service is called `n0t3b00k`. Otherwise docker compose might have issues when creating the networks, since it uses the directory name (in this case `service`) as prefix for the created networks, which might cause collisions with other services running on the same machine.
4. You **MUST** coordinate your published ports with the other service authors to avoid port collisions when starting two services on one vulnbox.

### Checker

The checker stores the flags in your service, retrieves them and checks whether your service works as intended.

There must be a directory called `checker` at the top level of your repository. The contents of this directory will be copied onto the checker VMs. The contents of this directory are not publicly accessible to the participants during the CTF.

With regards to the directory structure, the following conditions must be met:

1. Your checker **MUST** be able to be started simply by running `docker-compose up -d` in your `checker`-directory. This is exactly what the provisioning process on the checker VM does, thus it must not require any manual intervention to start the checker.
2. You **MUST** create a `.env`-file in your `checker` directory in which you set `COMPOSE_PROJECT_NAME=your_chosen_name_checker`, e.g. `COMPOSE_PROJECT_NAME=n0t3b00k_checker` if your service is called `n0t3b00k`.
3. You **MUST** coordinate your published port with the other service authors to avoid port collisions when starting two checkers on one checker VM. Note that while in the actual CTF the services and checkers will not be started on the same VM, you should avoid overlap between service ports and checker ports to allow starting the service and checker on the same VM in test setups (which is done e.g. during [enochecker_test-Workflow](#github-actions-ci-workflows))

For more details on the checker development, please refer to the [checker](../checker/checker) chapter of this documentation.

### GitHub Actions CI-Workflows

We require all services to be tested automatically using [enochecker_test](https://github.com/enowars/enochecker_test). `enochecker_test` is a test framework which interfaces with your checker over the network in the same way as the EnoEngine does. It includes some basic test cases (e.g. simply storing a flag and retrieving the flag) and also some special testcases based on issues we encountered in the past with previous checkers. **Note that enochecker_test succeeding DOES NOT guarantee that there are no issues with your service/checker!** When in doubt, you should write additional tests (e.g. unit tests) specific to your service. More details on testing your checker can be found in the [testing](../checker/testing) chapter.

We provide an example workflow for testing your service with `enochecker_test` in the [enowars-service-example](https://github.com/enowars/enowars-service-example/blob/main/.github/workflows/enochecker_test.yml) repository. Please copy that to your own repository and adjust as necessary.

Most importantly, you need to set the `ENOCHECKER_TEST_CHECKER_PORT` environment variable to match the published port of your checker.

The steps of the workflow can be summarized as following: 

- setup `enochecker_test`
- build and start your service
- build and start your checker
- run `enochecker_test` against your checker/service
- clean up after the tests are completed (this is necessary since we are using self-hosted GitHub Actions runners and do not use a fresh VM for each run)

### Documentation

You should include some (internal) documentation with your service. At least you should have a meaningful `README.md`. In addition, you are free to include any supporting documentation in the repository, for example in a separate `docs`-directory.

## Create a Service Repository

Create a private `enowars<season>-service-<your-service-name>` repository in the [Enowars Organization](https://github.com/enowars/). For example, for ENOWARS 5 and a service called `stldoctor` the repository would be called `enowars5-service-stldoctor`.

Give the correct permissions to your team (Blue/Yellow) by going to ` Settings -> Access -> Collaborators and teams` in your repository settings and giving `Read`-access to the team called e.g. `ENOWARS7-Blue` (if the current instance of ENOWARS is 7 and you are on the blue team).

Structure the repository as described above.

Begin developing your service and checker, making sure to commit, push and test often. You should try to get `enochecker_test` to pass as early as possible using a minimal implementation of your checker (e.g. a single putflag/getflag) and then, as you continue with the development of the service and add aditional checker functionality, ensure that the tests keep passing.

--8<-- "includes/abbreviations.md"
