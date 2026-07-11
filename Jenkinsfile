pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '385936845313'
        AWS_REGION     = 'ap-south-2' // Hyderabad region
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        // Fixed: Use placeholder here, we evaluate it cleanly inside the first stage
        COMMIT_SHA     = '' 
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
                    // Cleanly evaluate and set environment variable inside a script block
                    env.COMMIT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
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
}

def buildService(String serviceName) {
    echo "--- Processing ${serviceName} ---"
    
    // 1 & 2. Build, Compile, and Unit Test via Maven
    echo "Compiling, testing, and packaging dependencies for ${serviceName}..."
    // This executes your clean maven verification step inside each service subdirectory
    sh "mvn -f ${serviceName}/pom.xml clean verify"
    
    // 3. Docker Build Stage
    String imageTag = "${REGISTRY_URL}/${serviceName}:${env.COMMIT_SHA}"
    String latestTag = "${REGISTRY_URL}/${serviceName}:latest"
    
    echo "Building container images for ${serviceName}..."
    def appImage = docker.build(imageTag, "-f ./infra/docker/${serviceName}/Dockerfile .")
    
    // 4. Vulnerability Scan Stage (Trivy)
    echo "Scanning ${serviceName} image for critical vulnerabilities..."
    sh "trivy image --exit-code 1 --severity CRITICAL --no-progress ${imageTag}"
    
    // 5. Push Image Stage
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding', 
        credentialsId: 'aws-credentials', 
        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
    ]]) {
        echo "Authenticating and pushing image to AWS ECR..."
        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
        
        // Push commit SHA tag
        sh "docker push ${imageTag}"
        
        // Tag and push latest tag
        sh "docker tag ${imageTag} ${latestTag}"
        sh "docker push ${latestTag}"
    }
}
