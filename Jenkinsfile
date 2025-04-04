pipeline {
    agent any
    environment {
        BLUE_IP = "54.221.135.197"
        GREEN_IP = "34.239.23.73"
        NGINX_SERVER = "34.204.247.221"  // Nginx is on the same machine as Jenkins
        REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
        DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
        APP_DIR = "/home/ubuntu/app"
        ACTIVE_ENV = ''
        INACTIVE_ENV = ''
        FIRST_DEPLOYMENT = "false"
    }

    stages {
        stage('Check First-Time Deployment') {
            steps {
                script {
                    def activeEnvFile = "/etc/nginx/active_env"
    
                    if (fileExists(activeEnvFile)) {
                        env.ACTIVE_ENV = sh(script: "cat ${activeEnvFile}", returnStdout: true).trim()
                    }
                
                    if (!env.ACTIVE_ENV) {
                        env.ACTIVE_ENV = "blue" // Default to blue if the file is empty or missing
                    }
                
                    env.INACTIVE_ENV = env.ACTIVE_ENV == "blue" ? "green" : "blue"
                    echo "Active Environment: ${env.ACTIVE_ENV}"
                    echo "Inactive Environment: ${env.INACTIVE_ENV}"
                }
            }
        }

        stage('Docker Hub Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }
                }
            }
        }

        stage('Deploy to Target Environment') {
            agent { label env.INACTIVE_ENV ? "${env.INACTIVE_ENV}-server" : "green-server" }
            steps {
                script {
                    try {
                        sh """
                        rm -rf ${APP_DIR}
                        git clone ${REPO_URL} ${APP_DIR}
                        cd ${APP_DIR}
                        docker build . -t ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
                        docker push ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
                        docker stop \$(docker ps -q) || true
                        docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
                        """
                        currentBuild.result = 'SUCCESS'
                    } catch (Exception e) {
                        echo "${env.INACTIVE_ENV} deployment failed! No traffic switch."
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }

        stage('Setup Nginx for First Deployment') {
            when { expression { env.FIRST_DEPLOYMENT == "true" } }
            steps {
                script {
                    echo "Setting up Nginx for first deployment..."
                    sh """
                    echo '${env.ACTIVE_ENV}' | sudo tee /etc/nginx/active_env > /dev/null
                    sudo sed -i 's/server PLACEHOLDER_IP;/server ${BLUE_IP};/' /etc/nginx/sites-available/default
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Switch Traffic to New Deployment') {
            when { expression { env.FIRST_DEPLOYMENT == "false" && currentBuild.result == 'SUCCESS' } }
            steps {
                script {
                    def targetIp = (env.INACTIVE_ENV == "blue") ? BLUE_IP : GREEN_IP
                    sh """
                    sudo sed -i 's/server ${ACTIVE_ENV}_IP;/server ${targetIp};/' /etc/nginx/sites-available/default
                    echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Handle Failure Case (Rollback)') {
            when { expression { currentBuild.result == 'FAILURE' } }
            steps {
                script {
                    echo "Deployment failed. Keeping traffic on ${env.ACTIVE_ENV} environment."
                }
            }
        }
    }
}
