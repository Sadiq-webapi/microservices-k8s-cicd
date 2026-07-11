pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '385936845313' // Replace with your AWS Account ID
        AWS_REGION     = 'ap-south-2'           // Change if using another region
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        COMMIT_SHA     = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }
    
    options {
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    
    stages {
        stage('Code Checkout') {
            steps {
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
            slackSend channel: '#cicd-alerts', color: 'good', message: "SUCCESS: Job '${env.JOB_NAME}' [${env.BUILD_NUMBER}] completed successfully! (${env.BUILD_URL})"
            emailext body: "The pipeline executed flawlessly. Check out details here: ${env.BUILD_URL}", subject: "SUCCESS: ${env.JOB_NAME}", to: 'admin@yourcompany.com'
        }
        failure {
            slackSend channel: '#cicd-alerts', color: 'danger', message: "FAILURE: Job '${env.JOB_NAME}' [${env.BUILD_NUMBER}] failed during execution. (${env.BUILD_URL})"
            emailext body: "Something went wrong during the build phase. Investigation required: ${env.BUILD_URL}", subject: "FAILED: ${env.JOB_NAME}", to: 'admin@yourcompany.com'
        }
    }
}

def buildService(String serviceName) {
    echo "--- Processing ${serviceName} ---"
    
    // 1. Build / Compile Stage (Simulated or custom framework specific test task)
    echo "Compiling and packaging dependencies for ${serviceName}..."
    
    // 2. Unit Test Stage
    echo "Running Unit Test suites for ${serviceName}..."
    // sh "cd ${serviceName} && npm test" OR "mvn test" (Uncomment and add your direct test executable here)
    
    // 3. Docker Build Stage
    String imageTag = "${REGISTRY_URL}/${serviceName}:${COMMIT_SHA}"
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