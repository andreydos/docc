pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
      env:
        - name: AWS_REGION
          value: us-west-2
        - name: AWS_SDK_LOAD_CONFIG
          value: "true"
    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - 99d
"""
    }
  }

  environment {
    ECR_REGISTRY = "469935552561.dkr.ecr.us-west-2.amazonaws.com"
    IMAGE_NAME   = "lesson-8-9-django"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"
    CHART_VALUES = "lesson-8-9/charts/django-app/values.yaml"
    GIT_BRANCH   = "lesson-8-9"
    COMMIT_EMAIL = "jenkins@localhost"
    COMMIT_NAME  = "jenkins"
  }

  stages {
    stage('Prepare') {
      steps {
        container('git') {
          sh 'git config --global --add safe.directory "$WORKSPACE"'
          script {
            def message = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
            env.SKIP_BUILD = message.contains('[skip ci]') ? 'true' : 'false'
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        environment name: 'SKIP_BUILD', value: 'false'
      }
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context "$WORKSPACE/django" \
              --dockerfile "$WORKSPACE/django/Dockerfile" \
              --destination "$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      when {
        environment name: 'SKIP_BUILD', value: 'false'
      }
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
            sh '''
              set -eu
              git config --global --add safe.directory "$WORKSPACE"
              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"
              git checkout -B "$GIT_BRANCH"
              sed -i "s/^  tag: .*/  tag: ${IMAGE_TAG}/" "$CHART_VALUES"
              git add "$CHART_VALUES"
              if git diff --cached --quiet; then
                echo "Chart tag is already ${IMAGE_TAG}"
                exit 0
              fi
              git commit -m "Update image tag to ${IMAGE_TAG} [skip ci]"
              git push "https://${GIT_USERNAME}:${GIT_PAT}@github.com/andreydos/docc.git" "HEAD:${GIT_BRANCH}"
            '''
          }
        }
      }
    }
  }
}
