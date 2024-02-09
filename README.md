# Coworking Space Service Extension

The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

This project is a simulation of a DevOps engineer who are collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide is a functions as expected locally and we are expected to help build a pipeline to deploy it in Kubernetes.

# Project Instructions
1. Set up a Postgres database with a Helm Chart
2. Create a Dockerfile for the Python application. Use a base image that is Python-based.
3. Write a simple build pipeline with AWS CodeBuild to build and push a Docker image into AWS ECR
4. Create a service and deployment using Kubernetes configuration files to deploy the application
5. Check AWS CloudWatch for application logs

# Workspace Environment Requirements

## Local Resources Requirements
You'll need these tools to compete this project.

1. Python Environment - run Python 3.6+ applications and install Python dependencies via pip
2. Docker CLI - build and run Docker images locally
3. kubectl - run commands against a Kubernetes cluster
4. helm - apply Helm Charts to a Kubernetes cluster
5. GitHub - pull and clone code

## Remote Resource Requirements
This project utilizes Amazon Web Services (AWS). You'll need AWS account on the next page. The AWS resources you'll need to use for the project include:

1. AWS CLI
2. AWS CodeBuild - build Docker images remotely
3. AWS ECR - host Docker images
4. Kubernetes Environment with AWS EKS - run applications in k8s
5. AWS CloudWatch - monitor activity and logs in EKS

# Project Setup & Test
### 1. **Configure a Database**
Set up a Postgres database using a Helm Chart.

    1. Set up Bitnami Repo
        ```helm repo add bitnami-postgres https://charts.bitnami.com/bitnami```

    2. **Install PostgreSQL Helm Chart**
    ```helm install <SERVICE_NAME> <REPO_NAME>/postgresql```

    This should set up a Postgre deployment at ```<SERVICE_NAME>-postgresql.default.svc.cluster.local``` in your Kubernetes cluster. You can verify it by running ```kubectl svc```

    By default, it will create a username postgres. The password can be retrieved with the following command:

    ```
    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default <SERVICE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

    echo $POSTGRES_PASSWORD
    ```

    3. Test Database Connection The database is accessible within the cluster. This means that when you will have some issues connecting to it via your local environment.

    *You can either connect to a pod that has access to the cluster or connect remotely via Port Forwarding*

    * Connecting Via Port Forwarding
    ```kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
        PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432```
    * Connecting Via a Pod
    ```kubectl exec -it <POD_NAME> bash
    PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@<SERVICE_NAME>:5432/postgres -c <COMMAND_HERE>```
    4. Run Seed Files We will need to run the seed files in db/ in order to create the tables and populate them with data.
    ```kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>```


### 2. Running the Analytics Application Locally
In the analytics/ directory:

1. Install dependencies
```pip install -r requirements.txt```

2. Run the application (see below regarding environment variables)
```<ENV_VARS> python app.py```

There are multiple ways to set environment variables in a command. They can be set per session by running export `KEY=VAL` in the command line or they can be prepended into your command.

* `DB_USERNAME`
* `DB_PASSWORD`
* `DB_HOST (defaults to 127.0.0.1)`
* `DB_PORT (defaults to 5432)`
* `DB_NAME (defaults to postgres)`

If we set the environment variables by prepending them, it would look like the following:

```DB_USERNAME=username_here DB_PASSWORD=password_here python app.py```

The benefit here is that it's explicitly set. However, note that the DB_PASSWORD value is now recorded in the session's history in plaintext. There are several ways to work around this including setting environment variables in a file and sourcing them in a terminal session.

3. Verifying The Application

* Generate report for check-ins grouped by dates `curl <BASE_URL>/api/reports/daily_usage`
* Generate report for check-ins grouped by users `curl <BASE_URL>/api/reports/user_visits`