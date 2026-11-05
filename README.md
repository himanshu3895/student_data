# StudentApp

This project was generated using [Angular CLI](https://github.com/angular/angular-cli) version 22.2.6.

## Development server

To start a local development server, run:

```bash
ng serve
```

Once the server is running, open your browser and navigate to `http://localhost:4200/`. The application will automatically reload whenever you modify any of the source files.

## Code scaffolding

Angular CLI includes powerful code scaffolding tools. To generate a new component, run:

```bash
ng generate component component-name
```

For a complete list of available schematics (such as `components`, `directives`, or `pipes`), run:

```bash
ng generate --help
```

## Building

To build the project run:

```bash
ng build
```

This will compile your project and store the build artifacts in the `dist/` directory. By default, the production build optimizes your application for performance and speed.

## Jenkins deployment

The root `Jenkinsfile` checks out the frontend GitHub repository configured in the Jenkins job, builds the Angular app and Docker image, pushes it to the Minikube registry, then updates the `frontend` Deployment and waits for its rollout. The image tag is the first seven characters of the checked-out commit followed by the India date and time, for example `8dsgt6a-2026-11-04-08-30-17`.

Create a Pipeline job pointing at the frontend GitHub repository and configure a Jenkins build agent with the label `minikube-docker`. The agent needs Node.js/npm, Docker CLI connected to a Docker daemon, and `kubectl` configured for the `devops-lab` cluster. Configure the Docker daemon to allow the cluster registry at `192.168.58.2:30500` as an insecure registry. The agent's Kubernetes identity must be allowed to update and watch Deployments in `devops`; the existing `jenkins-deployer` service account has this access when used by an in-cluster agent.

If the Minikube node IP changes, update `REGISTRY` in the Jenkinsfile. The Jenkins controller currently runs without Docker, kubectl, or Node.js, so run builds on a separate configured agent rather than the controller.

### Deploy an image with Helm

The chart is in `helm/frontend`; it manages the existing `frontend` Deployment and Service while leaving the shared `app-ingress` alone. In Jenkins, create a second Pipeline job pointing at the same frontend GitHub repository, with Script Path `Jenkinsfile.helm-deploy` and a build agent labelled `minikube-build-helm`. It checks out, builds, tags and pushes the frontend image, then deploys that exact tag with Helm. The tag uses the first seven commit characters and India date/time. The agent needs Node.js/npm, Docker with the registry configured as insecure, Helm 3.17 or newer, and kubectl access to `devops-lab`.

The currently deployed Jenkins service account lacks permissions for Helm's release records, which Helm stores as Kubernetes Secrets. If the agent uses `devops/jenkins-deployer`, apply `helm/frontend/jenkins-helm-rbac.yaml` once with a cluster administrator. Helm's `--take-ownership` option lets the first release adopt the existing frontend Deployment and Service. The chart intentionally does not create or alter the shared Ingress.

### Deploy the backend with Helm

The backend chart is in `helm/backend`; it manages the existing `backend` Deployment and Service, reads `MONGO_URI` from the existing `mongo-secret`, and leaves the shared `app-ingress` unchanged. Create another Pipeline job using the frontend GitHub repository as its SCM, Script Path `Jenkinsfile.backend-helm-deploy`, and agent label `minikube-build-helm`. The pipeline checks out the backend repository, builds and pushes its image using the first seven backend commit characters plus India date/time, then deploys that exact tag with Helm. Configure `BACKEND_REPO_URL` as a Jenkins agent/node environment variable; the backend branch defaults to `main`. The backend checkout uses Jenkins credential ID `github-repo`. Create a Jenkins Secret file credential with ID `backend-pip-conf` for the backend Dockerfile's BuildKit pip.conf mount. The agent needs Git, Docker with BuildKit, Helm 3.17 or newer, kubectl, Minikube registry access, and permission to read `mongo-secret`. The Helm release Secrets permission described above is also required when using `jenkins-deployer`; the first Helm deployment adopts the existing backend resources.

### Jenkins credentials and agent

Add a Global credential with ID `github-repo`, kind **Username with password**: use your GitHub username and a GitHub token with read access to the frontend and backend repositories as the password. Select this credential in the frontend Pipeline job's SCM configuration; the backend checkout already references the same ID. Keep the token inside Jenkins and do not put it in a repository URL or Jenkinsfile.

The local Minikube registry at `192.168.58.2:30500` currently has no authentication, so no registry credential is required. For a private backend repository, `backend-pip-conf` must be a **Secret file** credential containing the pip configuration used by its Dockerfile.

The Jenkins agent's connection secret is generated when you create an inbound agent node in Jenkins; it is not a GitHub credential. If the build agent runs as a pod inside this cluster, give it the `devops/jenkins-deployer` service account for Kubernetes access and install the tools required by its label. The current Jenkins controller has no Docker, kubectl, Node.js, or Helm, so it cannot serve as the build agent without those tools.

## Running unit tests

To execute unit tests with the [Vitest](https://vitest.dev/) test runner, use the following command:

```bash
ng test
```

## Running end-to-end tests

For end-to-end (e2e) testing, run:

```bash
ng e2e
```

Angular CLI does not come with an end-to-end testing framework by default. You can choose one that suits your needs.

## Additional Resources

For more information on using the Angular CLI, including detailed command references, visit the [Angular CLI Overview and Command Reference](https://angular.dev/tools/cli) page.
