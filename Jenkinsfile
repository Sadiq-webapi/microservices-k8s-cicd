pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '385936845313'
        AWS_REGION     = 'ap-south-2'
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    options {
        timeout(time: 1, unit: 'HOURS')
    }

    stages {

        stage('Code Checkout') {
            steps {
                cleanWs()
                checkout scm

                script {
                    env.COMMIT_SHA = bat(
                        script: '@git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Commit SHA: ${env.COMMIT_SHA}"
                }
            }
        }

        stage('Parallel Microservice Build & Verify') {
            parallel {

                stage('User Service') {
                    steps {
                        script {
                            buildService('user-service')
                        }
                    }
                }

                stage('Order Service') {
                    steps {
                        script {
                            buildService('order-service')
                        }
                    }
                }

                stage('Payment Service') {
                    steps {
                        script {
                            buildService('payment-service')
                        }
                    }
                }

                stage('Notification Service') {
                    steps {
                        script {
                            buildService('notification-service')
                        }
                    }
                }

            }
        }
    }

    post {

        success {
            slackSend(
                tokenCredentialId: 'slack-token',
                channel: '#cicd-alerts',
                color: 'good',
                message: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}\n${env.BUILD_URL}"
            )

            emailext(
                subject: "SUCCESS: ${env.JOB_NAME}",
                body: "Pipeline completed successfully.\n\n${env.BUILD_URL}",
                to: "admin@yourcompany.com"
            )
        }

        failure {
            slackSend(
                tokenCredentialId: 'slack-token',
                channel: '#cicd-alerts',
                color: 'danger',
                message: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}\n${env.BUILD_URL}"
            )

            emailext(
                subject: "FAILED: ${env.JOB_NAME}",
                body: "Pipeline failed.\n\n${env.BUILD_URL}",
                to: "admin@yourcompany.com"
            )
        }
    }
}

def buildService(String serviceName) {

    echo "==============================="
    echo "Building ${serviceName}"
    echo "==============================="

    def currentCommit = env.COMMIT_SHA ?: "latest"

    def imageTag  = "${env.REGISTRY_URL}/${serviceName}:${currentCommit}"
    def latestTag = "${env.REGISTRY_URL}/${serviceName}:latest"

    stage("Build ${serviceName}") {

        echo "Running Maven Build..."

        bat "mvn clean verify -pl :${serviceName} -am -U"

        echo "Building Docker Image..."

        bat "docker build -t ${imageTag} -f ./${serviceName}/Dockerfile ./${serviceName}"

        echo "Skipping Trivy Scan"

     withCredentials([
   withCredentials([
    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
]) {

    echo "Configuring AWS CLI..."

    bat """
        aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
        aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%
        aws configure set default.region ${env.AWS_REGION}
    """

    echo "Logging into Amazon ECR..."

    bat """
        aws ecr get-login-password --region ${env.AWS_REGION} > ecr_pass.txt
        type ecr_pass.txt | docker login --username AWS --password-stdin ${env.REGISTRY_URL}
        del ecr_pass.txt
    """

    echo "Pushing Docker Image..."

    bat "docker push ${imageTag}"

    bat "docker tag ${imageTag} ${latestTag}"

    bat "docker push ${latestTag}"
}

echo "${serviceName} completed successfully."
