pipeline {
    agent any
    environment {
        BLUE_IP = "54.221.135.197"
        GREEN_IP = "34.239.23.73"
        NGINX_SERVER = "34.204.247.221"
        REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
        DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
        APP_DIR = "/home/ubuntu/app"
    }

    stages {
        stage('Initialize Environment') {
            steps {
                script {
                    def activeEnvFile = '/etc/nginx/active_env'
                    def isFirstDeploy = !fileExists(activeEnvFile)
                    
                    def activeEnv = isFirstDeploy ? "" : sh(script: "cat ${activeEnvFile}", returnStdout: true).trim()
                    def inactiveEnv = (activeEnv == "blue") ? "green" : "blue"
                    
                    env.ACTIVE_ENV = activeEnv
                    env.INACTIVE_ENV = inactiveEnv
                    env.FIRST_DEPLOYMENT = isFirstDeploy ? "true" : "false"

                    echo "🟢 Active Environment: ${env.ACTIVE_ENV}"
                    echo "🟠 Inactive Environment: ${env.INACTIVE_ENV}"
                    echo "🧾 First-Time Deployment: ${env.FIRST_DEPLOYMENT}"
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

        stage('Deploy to Inactive Server') {
            steps {
                script {
                    def label = "${env.INACTIVE_ENV}-server"
                    node(label) {
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
                        } catch (e) {
                            echo "❌ Deployment to ${env.INACTIVE_ENV}-server failed!"
                            currentBuild.result = 'FAILURE'
                            throw e
                        }
                    }
                }
            }
        }

        stage('Setup Nginx (First-Time Only)') {
            when { expression { env.FIRST_DEPLOYMENT == "true" } }
            steps {
                script {
                    echo "⚙️ Setting up Nginx for first-time deployment..."
                    sh """
                    echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo sed -i 's/server PLACEHOLDER_IP;/server ${env.INACTIVE_ENV == "blue" ? BLUE_IP : GREEN_IP};/' /etc/nginx/sites-available/default
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Switch Traffic to New Version') {
            when { 
                allOf {
                    expression { env.FIRST_DEPLOYMENT == "false" }
                    expression { currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                script {
                    def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                    def currentIp = (env.ACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                    
                    echo "🔄 Switching traffic to ${env.INACTIVE_ENV} (${targetIp})"

                    sh """
                    sudo sed -i 's/server ${currentIp}:5000;/server ${targetIp}:5000;/' /etc/nginx/sites-available/default
                    echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Rollback (If Deployment Fails)') {
            when { expression { currentBuild.result == 'FAILURE' } }
            steps {
                script {
                    echo "⚠️ Rollback activated. Keeping traffic on ${env.ACTIVE_ENV} environment."
                }
            }
        }
    }
}
