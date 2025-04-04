pipeline {
    agent any
    environment {
        BLUE_IP = "54.221.135.197"
        GREEN_IP = "34.239.23.73"
        NGINX_SERVER = "34.204.247.221"  // Since Nginx is on the same machine as Jenkins
        REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
        DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
        APP_DIR = "/home/ubuntu/app"
        ACTIVE_ENV = ''
        INACTIVE_ENV = ''
        FIRST_DEPLOYMENT = false
    }

    stages {
        stage('Check First-Time Deployment') {
            steps {
                script {
                    def checkEnvExists = sh(script: "[ -f /etc/nginx/active_env ] && echo exists || echo missing", returnStdout: true).trim()
                    if (checkEnvExists == "missing") {
                        echo "First-time deployment detected!"
                        FIRST_DEPLOYMENT = true
                        ACTIVE_ENV = "blue"
                        INACTIVE_ENV = "green"
                    } else {
                        ACTIVE_ENV = sh(script: "cat /etc/nginx/active_env", returnStdout: true).trim()
                        INACTIVE_ENV = (ACTIVE_ENV == 'blue') ? 'green' : 'blue'
                    }
                    echo "Active Environment: ${ACTIVE_ENV}"
                    echo "Inactive Environment: ${INACTIVE_ENV}"
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
            agent { label "${INACTIVE_ENV}-server" }
            steps {
                script {
                    try {
                        sh """
                        rm -rf ${APP_DIR}
                        git clone ${REPO_URL} ${APP_DIR}
                        cd ${APP_DIR}
                        docker build . -t ${DOCKER_HUB_REPO}:${INACTIVE_ENV}
                        docker push ${DOCKER_HUB_REPO}:${INACTIVE_ENV}
                        docker stop \$(docker ps -q) || true
                        docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:${INACTIVE_ENV}
                        """
                        currentBuild.result = 'SUCCESS'
                    } catch (Exception e) {
                        echo "${INACTIVE_ENV} deployment failed! No traffic switch."
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }

        stage('Setup Nginx for First Deployment') {
            when { expression { FIRST_DEPLOYMENT } }
            steps {
                script {
                    echo "Setting up Nginx for first deployment..."
                    sh """
                    echo '${ACTIVE_ENV}' | sudo tee /etc/nginx/active_env > /dev/null
                    sudo sed -i 's/server PLACEHOLDER_IP;/server ${BLUE_IP};/' /etc/nginx/sites-available/default
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Switch Traffic to New Deployment') {
            when { expression { !FIRST_DEPLOYMENT && currentBuild.result == 'SUCCESS' } }
            steps {
                script {
                    def targetIp = (INACTIVE_ENV == "blue") ? BLUE_IP : GREEN_IP
                    sh """
                    sudo sed -i 's/server ${ACTIVE_ENV}_IP;/server ${targetIp};/' /etc/nginx/sites-available/default
                    echo '${INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Handle Failure Case (Rollback)') {
            when { expression { currentBuild.result == 'FAILURE' } }
            steps {
                script {
                    echo "Deployment failed. Keeping traffic on ${ACTIVE_ENV} environment."
                }
            }
        }
    }
}
