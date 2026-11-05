pipeline {
  agent { label 'minikube-docker' }

  environment {
    REGISTRY = '192.168.58.2:30500'
    IMAGE_REPOSITORY = 'angular-frontend'
    NAMESPACE = 'devops'
    DEPLOYMENT = 'frontend'
    CONTAINER = 'frontend'
  }

  stages {
    stage('Checkout GitHub') {
      steps {
        checkout scm
      }
    }

    stage('Build Angular') {
      steps {
        sh 'node --version'
        sh 'npm ci'
        sh 'npm run build'
      }
    }

    stage('Create Image Tag') {
      steps {
        script {
          def commit = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
          def buildTime = sh(script: "TZ=Asia/Kolkata date '+%Y-%m-%d-%H-%M-%S'", returnStdout: true).trim()
          env.IMAGE_TAG = "${commit}-${buildTime}"
          env.IMAGE = "${env.REGISTRY}/${env.IMAGE_REPOSITORY}:${env.IMAGE_TAG}"
          echo "Building image ${env.IMAGE}"
        }
      }
    }

    stage('Build and Push Image') {
      steps {
        sh 'docker info >/dev/null'
        sh 'docker build --tag "$IMAGE" .'
        sh 'docker push "$IMAGE"'
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh 'kubectl -n "$NAMESPACE" set image "deployment/$DEPLOYMENT" "$CONTAINER=$IMAGE"'
        sh 'kubectl -n "$NAMESPACE" rollout status "deployment/$DEPLOYMENT" --timeout=180s'
      }
    }
  }
}
