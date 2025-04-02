// pipeline {
//     agent any
//     environment {
//         // Fetch public IPs dynamically from AWS
//         BLUE_IP = "54.221.135.197"
//         GREEN_IP = "34.239.23.73"
//         NGINX_IP = "34.204.247.221"
//         DEPLOYMENT_FILE = "/var/lib/jenkins/workspace/django-simple-app/deployment_count.txt"
//         REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
//         DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
//         APP_DIR = "/home/ubuntu/app"
//     }


//     stages {
//         stage('Docker Hub Login') {
//             steps {
//                 script {
//                     withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                         sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
//                     }
//                 }
//             }
//         }

//         stage('Read Deployment Count') {
//             steps {
//                 script {
//                     if (fileExists(DEPLOYMENT_FILE)) {
//                         DEPLOYMENT_COUNT = readFile(DEPLOYMENT_FILE).trim().toInteger()
//                     } else {
//                         DEPLOYMENT_COUNT = 0
//                     }
//                 }
//             }
//         }

//         stage('Deploy to Blue (First Commit)') {
//             when { expression { DEPLOYMENT_COUNT == 0 } }
//             agent { label 'blue-server' }
//             steps {
//                 sh """
//                 rm -rf ${APP_DIR}
//                 git clone ${REPO_URL} ${APP_DIR}
//                 cd ${APP_DIR}
//                 docker build -t ${DOCKER_HUB_REPO}:previous .
//                 docker push ${DOCKER_HUB_REPO}:previous
//                 docker stop \$(docker ps -q) || true
//                 docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:previous
//                 """
//             }
//         }

//         stage('Deploy to Green (Second Commit)') {
//             when { expression { DEPLOYMENT_COUNT == 1 } }
//             agent { label 'green-server' }
//             steps {
//                 script {
//                     try {
//                         sh """
//                         rm -rf ${APP_DIR}
//                         git clone ${REPO_URL} ${APP_DIR}
//                         cd ${APP_DIR}
//                         docker build -t ${DOCKER_HUB_REPO}:latest .
//                         docker push ${DOCKER_HUB_REPO}:latest
//                         docker stop \$(docker ps -q) || true
//                         docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:latest
//                         """
//                     } catch (Exception e) {
//                         echo "Green deployment failed! Keeping traffic on Blue."
//                         currentBuild.result = 'FAILURE'
//                     }
//                 }
//             }
//         }

//         stage('Move Green to Blue & Deploy to Green (Third Commit Onward)') {
//             when { expression { DEPLOYMENT_COUNT >= 2 } }
//             parallel {
//                 stage('Move Green to Blue') {
//                     agent { label 'blue-server' }
//                     steps {
//                         script {
//                             try {
//                                 sh """
//                                 docker tag ${DOCKER_HUB_REPO}:latest ${DOCKER_HUB_REPO}:previous
//                                 docker push ${DOCKER_HUB_REPO}:previous
//                                 docker stop \$(docker ps -q) || true
//                                 docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:previous
//                                 """
//                             } catch (Exception e) {
//                                 echo "Error while moving Green to Blue!"
//                             }
//                         }
//                     }
//                 }

//                 stage('Deploy New to Green') {
//                     agent { label 'green-server' }
//                     steps {
//                         script {
//                             try {
//                                 sh """
//                                 rm -rf ${APP_DIR}
//                                 git clone ${REPO_URL} ${APP_DIR}
//                                 cd ${APP_DIR}
//                                 docker build -t ${DOCKER_HUB_REPO}:latest .
//                                 docker push ${DOCKER_HUB_REPO}:latest
//                                 docker stop \$(docker ps -q) || true
//                                 docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:latest
//                                 """
//                             } catch (Exception e) {
//                                 echo "Green deployment failed! Rolling back..."
//                                 currentBuild.result = 'FAILURE'
//                             }
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Handle Failure Case (Rollback to Blue)') {
//             when { expression { DEPLOYMENT_COUNT >= 2 && currentBuild.result == 'FAILURE' } }
//             agent { label 'blue-server' }
//             steps {
//                 sh """
//                 echo "Rolling back to Blue..."
//                 docker stop \$(docker ps -q) || true
//                 docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:previous
//                 """
//             }
//         }

//         stage('Switch Traffic to Green') {
//             when { expression { DEPLOYMENT_COUNT >= 1 && currentBuild.result != 'FAILURE' } }
//             steps {
//                 script {
//                     sh """
//                     echo "export ACTIVE_SERVER=${GREEN_IP}" | sudo tee /etc/environment
//                     source /etc/environment
//                     sudo systemctl restart nginx
//                     """
//                 }
//             }
//         }

//         stage('Update Deployment Count') {
//             steps {
//                 script {
//                     DEPLOYMENT_COUNT += 1
//                     writeFile(file: DEPLOYMENT_FILE, text: DEPLOYMENT_COUNT.toString())
//                 }
//             }
//         }

//         // stage('Send Email Notification') {
//         //     steps {
//         //         script {
//         //             def subject = (currentBuild.result == 'SUCCESS') ? "Deployment Succeeded" : "Deployment Failed"
//         //             def body = (currentBuild.result == 'SUCCESS') ? "Deployment to Green was successful. Traffic switched." : "Deployment to Green failed. Rolled back to Blue."

//         //             emailext (
//         //                 subject: subject,
//         //                 body: body,
//         //                 to: 'your-email@example.com'
//         //             )
//         //         }
//         //     }
//         // }
//     }
// }

pipeline {
    agent any
    environment {
        BLUE_IP = "54.221.135.197"
        GREEN_IP = "34.239.23.73"
        NGINX_IP = "34.204.247.221"
        DEPLOYMENT_FILE = "/var/lib/jenkins/workspace/django-simple-app/deployment_count.txt"
        REPO_URL = "https://github.com/vishuhack/django_simple_app.git"
        DOCKER_HUB_REPO = "deepalidevops1975/django_simple_app"
        APP_DIR = "/home/ubuntu/app"
    }

    stages {
        stage('Docker Hub Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker info
                        """
                    }
                }
            }
        }

        stage('Read Deployment Count') {
            steps {
                script {
                    env.DEPLOYMENT_COUNT = fileExists(DEPLOYMENT_FILE) ? readFile(DEPLOYMENT_FILE).trim().toInteger() : 0
                    echo "Current Deployment Count: ${env.DEPLOYMENT_COUNT}"
                }
            }
        }

        stage('Deploy to Blue (First Commit)') {
            when { expression { env.DEPLOYMENT_COUNT.toInteger() == 0 } }
            agent { label 'blue-server' }
            steps {
                sh """
                rm -rf ${APP_DIR}
                git clone ${REPO_URL} ${APP_DIR}
                cd ${APP_DIR}
                docker build . -t ${DOCKER_HUB_REPO}:previous
                docker push ${DOCKER_HUB_REPO}:previous || exit 1
                docker stop \$(docker ps -q) || true
                docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:previous
                """
            }
        }

        stage('Deploy to Green (Second Commit)') {
            when { expression { env.DEPLOYMENT_COUNT.toInteger() == 1 } }
            agent { label 'green-server' }
            steps {
                script {
                    try {
                        sh """
                        rm -rf ${APP_DIR}
                        git clone ${REPO_URL} ${APP_DIR}
                        cd ${APP_DIR}
                        docker build -t ${DOCKER_HUB_REPO}:latest .
                        docker push ${DOCKER_HUB_REPO}:latest || exit 1
                        docker stop \$(docker ps -q) || true
                        docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:latest
                        """
                    } catch (Exception e) {
                        echo "Green deployment failed! Keeping traffic on Blue."
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }

        stage('Move Green to Blue & Deploy to Green (Third Commit Onward)') {
            when { expression { env.DEPLOYMENT_COUNT.toInteger() >= 2 } }
            parallel {
                stage('Move Green to Blue') {
                    agent { label 'blue-server' }
                    steps {
                        script {
                            try {
                                sh """
                                docker tag ${DOCKER_HUB_REPO}:latest ${DOCKER_HUB_REPO}:previous
                                docker push ${DOCKER_HUB_REPO}:previous || exit 1
                                docker stop \$(docker ps -q) || true
                                docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:previous
                                """
                            } catch (Exception e) {
                                echo "Error while moving Green to Blue!"
                            }
                        }
                    }
                }

                stage('Deploy New to Green') {
                    agent { label 'green-server' }
                    steps {
                        script {
                            try {
                                sh """
                                rm -rf ${APP_DIR}
                                git clone ${REPO_URL} ${APP_DIR}
                                cd ${APP_DIR}
                                docker build -t ${DOCKER_HUB_REPO}:latest .
                                docker push ${DOCKER_HUB_REPO}:latest || exit 1
                                docker stop \$(docker ps -q) || true
                                docker run -d -p 5000:5000 ${DOCKER_HUB_REPO}:latest
                                """
                            } catch (Exception e) {
                                echo "Green deployment failed! Rolling back..."
                                currentBuild.result = 'FAILURE'
                            }
                        }
                    }
                }
            }
        }

        stage('Switch Traffic to Green') {
            when { expression { env.DEPLOYMENT_COUNT.toInteger() >= 1 && currentBuild.result != 'FAILURE' } }
            steps {
                script {
                    sh """
                    sudo sed -i 's/server ${BLUE_IP};/server ${GREEN_IP};/' /etc/nginx/sites-available/default
                    sudo systemctl restart nginx
                    """
                }
            }
        }

        stage('Update Deployment Count') {
            steps {
                script {
                    env.DEPLOYMENT_COUNT = (env.DEPLOYMENT_COUNT.toInteger() + 1).toString()
                    writeFile(file: DEPLOYMENT_FILE, text: env.DEPLOYMENT_COUNT)
                }
            }
        }
    }
}
