pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '385936845313'
        AWS_REGION     = 'ap-south-2' // Hyderabad region
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }
    
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    
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
                        script { buildService('user-service') }
                    }
                }
                stage('Order Service') {
                    steps {
                        script { buildService('order-service') }
                    }
                }
                stage('Payment Service') {
                    steps {
                        script { buildService('payment-service') }
                    }
                }
                stage('Notification Service') {
                    steps {
                        script { buildService('notification-service') }
                    }
                }
            }
        }
    }
    
    post {
        success {
            slackSend tokenCredentialId: 'slack-token', channel: '#cicd-alerts', color: 'good', message: "SUCCESS: Job '${env.JOB_NAME}' [${env.BUILD_NUMBER}] completed successfully! (${env.BUILD_URL})"
            emailext body: "The pipeline executed flawlessly. Check out details here: ${env.BUILD_URL}", subject: "SUCCESS: ${env.JOB_NAME}", to: 'admin@yourcompany.com'
        }
        failure {
            slackSend tokenCredentialId: 'slack-token', channel: '#cicd-alerts', color: 'danger', message: "FAILURE: Job '${env.JOB_NAME}' [${env.BUILD_NUMBER}] failed during execution. (${env.BUILD_URL})"
            emailext body: "Something went wrong during the build phase. Investigation required: ${env.BUILD_URL}", subject: "FAILED: ${env.JOB_NAME}", to: 'admin@yourcompany.com'
        }
    }
}

def buildService(String serviceName) {

    echo "--- Processing ${serviceName} ---"

    String currentCommit = env.COMMIT_SHA ?: 'latest'
    String imageTag = "${REGISTRY_URL}/${serviceName}:${currentCommit}"
    String latestTag = "${REGISTRY_URL}/${serviceName}:latest"

    echo "Compiling, testing, and packaging dependencies for ${serviceName}..."
    bat "mvn clean verify -pl :${serviceName} -am -U"

    echo "Building container image for ${serviceName}..."
    bat "docker build -t ${imageTag} -f ./${serviceName}/Dockerfile ./${serviceName}"

    echo "Skipping Trivy image scan."

    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'aws-credentials',
        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
    ]]) {

        echo "Logging into Amazon ECR..."
        bat """
            aws ecr get-login-password --region ${AWS_REGION} > ecr_pass.txt
            type ecr_pass.txt | docker login --username AWS --password-stdin ${REGISTRY_URL}
            del ecr_pass.txt
        """

        echo "Pushing ${serviceName} image..."
        bat "docker push ${imageTag}"

        bat "docker tag ${imageTag} ${latestTag}"

        bat "docker push ${latestTag}"
    }

    echo "${serviceName} completed successfully."
}
