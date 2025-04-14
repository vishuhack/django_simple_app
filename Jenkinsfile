// pipeline {
//     agent any

//     environment {
//         NGINX_SERVER = "54.221.135.197" // 🧭 Your static Elastic IP for Nginx
//         REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
//         DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
//         APP_DIR = "/home/ubuntu/app"
//     }

//     stages {
//         stage('Fetch Dynamic IPs') {
//             steps {
//                 script {
//                     echo "🌐 Fetching Blue & Green EC2 IPs via AWS CLI..."

//                     env.BLUE_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=blue-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
//                     env.GREEN_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=green-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()

//                     echo "🔹 Blue Server IP: ${env.BLUE_IP}"
//                     echo "🟢 Green Server IP: ${env.GREEN_IP}"
//                     echo "📍 Nginx Server (Elastic IP): ${env.NGINX_SERVER}"
//                 }
//             }
//         }

//         stage('Initialize Environment') {
//             steps {
//                 script {
//                     def activeEnvFile = '/etc/nginx/active_env'
//                     def isFirstDeploy = !fileExists(activeEnvFile)
                    
//                     def activeEnv = isFirstDeploy ? "" : sh(script: "cat ${activeEnvFile}", returnStdout: true).trim()
//                     def inactiveEnv = (activeEnv == "blue") ? "green" : "blue"
                    
//                     env.ACTIVE_ENV = activeEnv
//                     env.INACTIVE_ENV = inactiveEnv
//                     env.FIRST_DEPLOYMENT = isFirstDeploy ? "true" : "false"

//                     echo "🟢 Active Environment: ${env.ACTIVE_ENV}"
//                     echo "🟠 Inactive Environment: ${env.INACTIVE_ENV}"
//                     echo "🧾 First-Time Deployment: ${env.FIRST_DEPLOYMENT}"
//                 }
//             }
//         }

//         stage('Docker Hub Login') {
//             steps {
//                 script {
//                     withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                         sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
//                     }
//                 }
//             }
//         }

//         stage('Deploy to Inactive Server') {
//             steps {
//                 script {
//                     def label = "${env.INACTIVE_ENV}-server"
//                     node(label) {
//                         try {
//                             sh """
//                             rm -rf ${APP_DIR}
//                             git clone ${REPO_URL} ${APP_DIR}
//                             cd ${APP_DIR}
//                             docker build . -t ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                             docker push ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                             docker stop \$(docker ps -q) || true
//                             docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                             """
//                             currentBuild.result = 'SUCCESS'
//                         } catch (e) {
//                             echo "❌ Deployment to ${env.INACTIVE_ENV}-server failed!"
//                             currentBuild.result = 'FAILURE'
//                             return
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Setup Nginx (First-Time Only)') {
//             when { expression { env.FIRST_DEPLOYMENT == "true" } }
//             steps {
//                 script {
//                     echo "⚙️ Setting up Nginx for first-time deployment..."
//                     sh """
//                     echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
//                     sudo sed -i 's/server PLACEHOLDER_IP;/server ${env.INACTIVE_ENV == "blue" ? BLUE_IP : GREEN_IP};/' /etc/nginx/sites-available/default
//                     sudo systemctl reload nginx
//                     """
//                 }
//             }
//         }

//         stage('Switch Traffic to New Version') {
//             when { 
//                 allOf {
//                     expression { env.FIRST_DEPLOYMENT == "false" }
//                     expression { currentBuild.result == 'SUCCESS' }
//                 }
//             }
//             steps {
//                 script {
//                     def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
//                     def currentIp = (env.ACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                    
//                     echo "🔄 Switching traffic to ${env.INACTIVE_ENV} (${targetIp})"

//                     sh """
//                     sudo sed -i 's/server ${currentIp}:5000;/server ${targetIp}:5000;/' /etc/nginx/sites-available/default
//                     echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
//                     sudo systemctl reload nginx
//                     """
//                 }
//             }
//         }

//         stage('Rollback (If Deployment Fails)') {
//             when { expression { currentBuild.result == 'FAILURE' } }
//             steps {
//                 script {
//                     echo "⚠️ Rollback activated. Keeping traffic on ${env.ACTIVE_ENV} environment."
//                 }
//             }
//         }
//     }
// }


// pipeline {
//     agent any

//     environment {
//         NGINX_SERVER = "54.221.135.197"
//         REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
//         DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
//         APP_DIR = "/home/ubuntu/app"
//         SSH_KEY = "/var/lib/jenkins/.ssh/deepali-linux-key.pem"
//     }

//     stages {
//         stage('Fetch Dynamic IPs') {
//             steps {
//                 script {
//                     echo "🌐 Fetching Blue & Green EC2 IPs via AWS CLI..."

//                     env.BLUE_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=blue-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
//                     env.GREEN_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=green-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()

//                     echo "🔹 Blue Server IP: ${env.BLUE_IP}"
//                     echo "🟢 Green Server IP: ${env.GREEN_IP}"
//                 }
//             }
//         }

//         stage('Initialize Environment') {
//             steps {
//                 script {
//                     def activeEnvFile = '/etc/nginx/active_env'
//                     def isFirstDeploy = !fileExists(activeEnvFile)

//                     def activeEnv = isFirstDeploy ? "" : sh(script: "cat ${activeEnvFile}", returnStdout: true).trim()
//                     def inactiveEnv = (activeEnv == "blue") ? "green" : "blue"

//                     env.ACTIVE_ENV = activeEnv
//                     env.INACTIVE_ENV = inactiveEnv
//                     env.FIRST_DEPLOYMENT = isFirstDeploy ? "true" : "false"

//                     echo "🟢 Active Environment: ${env.ACTIVE_ENV}"
//                     echo "🟠 Inactive Environment: ${env.INACTIVE_ENV}"
//                 }
//             }
//         }

//         stage('Docker Hub Login') {
//             steps {
//                 script {
//                     withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                         sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
//                     }
//                 }
//             }
//         }

//         stage('Deploy to Inactive Server via SSH') {
//             steps {
//                 script {
//                     def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP

//                     echo "🚀 Deploying to ${env.INACTIVE_ENV}-server (${targetIp})"

//                     sh """
//                     ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${targetIp} '
//                         rm -rf ${APP_DIR}
//                         git clone ${REPO_URL} ${APP_DIR}
//                         cd ${APP_DIR}
//                         docker build . -t ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                         docker push ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                         docker stop \$(docker ps -q) || true
//                         docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
//                     '
//                     """
//                 }
//             }
//         }

//         stage('Setup Nginx (First-Time Only)') {
//             when { expression { env.FIRST_DEPLOYMENT == "true" } }
//             steps {
//                 script {
//                     def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP

//                     echo "⚙️ Setting up Nginx for first-time deployment..."

//                     sh """
//                     echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
//                     sudo sed -i 's/server PLACEHOLDER_IP;/server ${targetIp}:5000;/' /etc/nginx/sites-available/default
//                     sudo systemctl reload nginx
//                     """
//                 }
//             }
//         }

//         stage('Switch Traffic to New Version') {
//             when { 
//                 allOf {
//                     expression { env.FIRST_DEPLOYMENT == "false" }
//                 }
//             }
//             steps {
//                 script {
//                     def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
//                     def currentIp = (env.ACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP

//                     echo "🔄 Switching traffic to ${env.INACTIVE_ENV} (${targetIp})"

//                     sh """
//                     sudo sed -i "s/server ${currentIp}:5000;/server ${targetIp}:5000;/" /etc/nginx/sites-available/default
//                     echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
//                     sudo systemctl reload nginx
//                     """

//                 }
//             }
//         }

//         stage('Rollback (If Deployment Fails)') {
//             when { expression { currentBuild.result == 'FAILURE' } }
//             steps {
//                 echo "⚠️ Rollback activated. Keeping traffic on ${env.ACTIVE_ENV} environment."
//             }
//         }
//     }
// }


pipeline {
    agent any

    environment {
        NGINX_SERVER = "54.221.135.197"
        REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
        DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
        APP_DIR = "/home/ubuntu/app"
        SSH_KEY = "/var/lib/jenkins/.ssh/deepali-linux-key.pem"
    }

    stages {
        stage('Fetch Dynamic IPs') {
            steps {
                script {
                    echo "🌐 Fetching Blue & Green EC2 IPs via AWS CLI..."
                    env.BLUE_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=blue-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
                    env.GREEN_IP = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=green-server' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
                    echo "🔹 Blue Server IP: ${env.BLUE_IP}"
                    echo "🟢 Green Server IP: ${env.GREEN_IP}"
                }
            }
        }

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

        stage('Deploy to Inactive Server via SSH') {
            steps {
                script {
                    try {
                        def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                        echo "🚀 Deploying to ${env.INACTIVE_ENV}-server (${targetIp})"

                        sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${targetIp} '
                            set -e
                            echo "🧹 Cleaning old Docker images..."
                            docker stop \$(docker ps -q) || true
                            docker rm \$(docker ps -a -q) || true
                            docker rmi -f ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV} || true
                            docker image prune -af || true

                            echo "📁 Cloning repo..."
                            rm -rf ${APP_DIR}
                            git clone ${REPO_URL} ${APP_DIR}
                            cd ${APP_DIR}

                            echo "🐳 Building image with no cache..."
                            docker build --no-cache . -t ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}

                            echo "📤 Pushing image to Docker Hub..."
                            docker push ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}

                            echo "🚀 Running container..."
                            docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:${env.INACTIVE_ENV}
                        '
                        """
                    } catch (Exception e) {
                        echo "❌ Deployment failed on ${env.INACTIVE_ENV}. Triggering rollback..."
                        currentBuild.result = 'FAILURE'
                        return
                    }
                }
            }
        }

        stage('Setup Nginx (First-Time Only)') {
            when { expression { env.FIRST_DEPLOYMENT == "true" } }
            steps {
                script {
                    def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                    echo "⚙️ Setting up Nginx for first-time deployment..."

                    sh """
                    echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo sed -i 's/server PLACEHOLDER_IP;/server ${targetIp}:5000;/' /etc/nginx/sites-available/default
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Switch Traffic to New Version') {
            when { 
                allOf {
                    expression { env.FIRST_DEPLOYMENT == "false" }
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                script {
                    def targetIp = (env.INACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP
                    def currentIp = (env.ACTIVE_ENV == "blue") ? env.BLUE_IP : env.GREEN_IP

                    echo "🔄 Switching traffic to ${env.INACTIVE_ENV} (${targetIp})"

                    sh """
                    sudo sed -i "s/server ${currentIp}:5000;/server ${targetIp}:5000;/" /etc/nginx/sites-available/default
                    echo '${env.INACTIVE_ENV}' | sudo tee /etc/nginx/active_env
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Rollback (If Deployment Fails)') {
            when { expression { currentBuild.result == 'FAILURE' } }
            steps {
                echo "⚠️ Rollback activated. Keeping traffic on ${env.ACTIVE_ENV} environment."
            }
        }

        stage('Send Deployment Email') 
        {
            steps 
            {
                script 
                {
                    def subject = ''
                    def body = ''
                    def recipient = 'aayushpaturkar2006@gmail.com'
                    def buildUrl = "${env.BUILD_URL}"  // Jenkins provides this env var automatically

                    if (currentBuild.result == null || currentBuild.result == 'SUCCESS') {
                        def deployedEnv = env.INACTIVE_ENV
                        def deployedIp = (deployedEnv == "blue") ? env.BLUE_IP : env.GREEN_IP

                        subject = "✅ Deployment Success on ${deployedEnv.toUpperCase()} Server"
                        body = """
                        <html>
                        <body>
                            <p>Hello,</p>

                            <p>✅ Your Django app has been successfully deployed on the <b>${deployedEnv.toUpperCase()}</b> server.</p>

                            <p>🌐 Access it at: <a href="http://${deployedIp}:5000">http://${deployedIp}:5000</a></p>

                            <p>🔍 <a href="${buildUrl}">View Console Output</a></p>

                            <br>
                            <p>Regards,<br>
                            Jenkins Blue-Green Pipeline</p>
                        </body>
                        </html>
                        """
                    } else {
                        def failedEnv = env.INACTIVE_ENV
                        def stableEnv = env.ACTIVE_ENV
                        def stableIp = (stableEnv == "blue") ? env.BLUE_IP : env.GREEN_IP

                        subject = "❌ Deployment Failed on ${failedEnv.toUpperCase()} Server"
                        body = """
                        <html>
                        <body>
                            <p>Hello,</p>

                            <p>❌ Deployment failed on the <b>${failedEnv.toUpperCase()}</b> server.</p>
                            <p>✅ The previous stable version is still running on the <b>${stableEnv.toUpperCase()}</b> server.</p>

                            <p>🌐 Access it at: <a href="http://${stableIp}:5000">http://${stableIp}:5000</a></p>

                            <p>📄 Please <a href="${buildUrl}">check the Jenkins Console Output</a> for detailed logs.</p>

                            <br>
                            <p>Regards,<br>
                            Jenkins Blue-Green Pipeline</p>
                        </body>
                        </html>
                        """
                    }
                        emailext(
                            subject: subject,
                            body: body,
                            to: recipient,
                            mimeType: 'text/html'
                        )
                }
            }
        }

        
    }

    post {
        failure {
            echo "🛑 Pipeline failed. Please check logs above."
        }
    }
}
