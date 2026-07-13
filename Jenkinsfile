pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '385936845313'
        AWS_REGION     = 'ap-south-2' // Hyderabad region
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        COMMIT_SHA     = '' 
        DOCKER_HOST    = 'tcp://127.0.0.1:2375'
    }
    
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Code Checkout') {
            steps {
                // Executing checkout first keeps the .git metadata active for parsing
                script {
                    def scmVariables = checkout scm
                    
                    if (scmVariables.GIT_COMMIT) {
                        env.COMMIT_SHA = scmVariables.GIT_COMMIT.substring(0, 7)
                    } else if (env.GIT_COMMIT) {
                        env.COMMIT_SHA = env.GIT_COMMIT.substring(0, 7)
                    } else {
                        // Resilient system level fallback parser for Windows
                        def rawCommit = bat(script: "@git rev-parse --short HEAD", returnStdout: true).trim()
                        def lines = rawCommit.split('\r?\n')
                        env.COMMIT_SHA = lines[lines.length - 1].trim()
                    }
                }
                // Wipe out residual target files safely after extracting git metrics
                cleanWs()
                checkout scm
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
    
    echo "Compiling, testing, and packaging dependencies for ${serviceName}..."
    bat "mvn clean verify -pl :${serviceName} -am -U"
    
    String imageTag = "${REGISTRY_URL}/${serviceName}:${env.COMMIT_SHA}"
    String latestTag = "${REGISTRY_URL}/${serviceName}:latest"
    
    echo "Building container images for ${serviceName}..."
    bat "docker build -t ${imageTag} -f ./infra/docker/${serviceName}/Dockerfile ."
    
    echo "Scanning ${serviceName} image for critical vulnerabilities..."
    bat "trivy image --exit-code 1 --severity CRITICAL --no-progress ${imageTag}"
    
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding', 
        credentialsId: 'aws-credentials', 
        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
    ]]) {
        echo "Authenticating and pushing image to AWS ECR..."
        bat "aws ecr get-login-password --region ${AWS_REGION} > ecr_pass.txt && type ecr_pass.txt | docker login --username AWS --password-stdin ${REGISTRY_URL} && del ecr_pass.txt"
        
        bat "docker push ${imageTag}"
        bat "docker tag ${imageTag} ${latestTag}"
        bat "docker push ${latestTag}"
    }
}
