/* Below is the sample jenkins file which mainly consists of 5 block the mian parent block is the "PIPELINE" block ,
   pipeline block has netsted block  eg , "environment" , "stages" and "post" , stages block has netsted block which is "steps"
   block. stages will be executed sequentially in an order they are mentioned.
   ====================================================================================================================
   NOTE:- this is the sample jenkins file which mentions signiicance and use of each stage, There is no need to add all the stages 
          in a single jenkins file this is just for reference.
          please read carefully the commented lines before including any stages into your jenkins file.
          we haev also uploaded a sample jenkins file in "examples" folder which you can  use in your project, as most of the stages 
          in that sample jenkins file will be used by your project, that jenkins file is ideal for Nodejs projects.
          this file is just for explainantion purpose. 
    ================================================================================================================================= */      


pipeline {
    agent any
    
    environment {                                                                          //if you want to pass any variables for the pipeline
      DOCKERHUB = credentials('dockerhub')                                                //credentials will be fetched from global credentials set in jenkins      
      GIT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim() //this one is custom variable which can be used in later stages of the file
    }
   
     tools {                         //tools if some specific tool is required to build the project , here 'nodejs-6.x' for node project
        nodejs 'nodejs-6.x'
     }
    stages {                                       
        stage('Build') {                                                                  //this is a stage which will clone the code from our git or any scm and will make it
            agent any
            steps {
                checkout scm                                                             //checkout scm step which is configured for a job in jenkins will get triggered
                sh 'make'                                                               // eg:- "npm install" can be include here
                stash includes: '**/target/*.jar', name: 'app'                          // couple of shell commands
            }
        }
        stage('Test on Linux') {                                                       //this stage will run unit testcatses on your code
            agent { 
                label 'linux'                                                          //this means test will run on linux machine
            }
            steps {
                unstash 'app' 
                sh 'make check'
            }
            post {
                always {
                    junit '**/target/*.xml'                                             //this step will run junit on code 
                }
            }
        }
        stage('Test on Windows') {                                                      //this stage will run test cases on windows machine
            agent {
                label 'windows'
            }
            steps {
                unstash 'app'
                bat 'make check' 
            }
            post {
                always {
                    junit '**/target/*.xml'
                }
            }
        }
        stage('Dockerhub login') {                                                      //this stage will do docker hub login
           steps {
               sh "sudo docker login -u $DOCKERHUB_USR -p $DOCKERHUB_PSW"
          }
         }
        stage('Docker build') {                                                         //stage for building docker images
           steps {
              sh 'env'
               sh "sudo docker build -t $DOCKERHUB_USR/${env.JOB_NAME}:${env.GIT_BRANCH}-${env.BUILD_NUMBER} ."
         }
        }
        stage('Docker push') {                                                            //this stage will push image to docker hub
           steps {                                                                        //steps to fetch the env variables, push the image and trigger st2 webhook 
             sh 'env'
             sh "sudo docker push $DOCKERHUB_USR/${env.JOB_NAME}:${env.GIT_BRANCH}-${env.BUILD_NUMBER}"
             sh "curl -k http://${env.ST2_URL}/api/v1/webhooks/codecommit -d '{\"name\": \"${env.JOB_NAME}\", \"build\": {\"branch\": \"${env.GIT_BRANCH}\", \"status\": \"SUCCESS\", \"number\": \"${env.BUILD_ID}\"}}' -H 'Content-Type: application/json' -H 'st2-api-key: ${env.ST2_API_KEY}'"
             sh "sudo docker rmi $DOCKERHUB_USR/${env.JOB_NAME}:${env.GIT_BRANCH}-${env.BUILD_NUMBER}"
          }
         }
      
      }
        post {                                      //this will cleanup the workspace after build and push is done on docker hub , this is not a stage this will run after all stages are done runnnig
        always {
            echo 'Janitor Cleaning the workspace'
            deleteDir() /* clean up our workspace */
     }
  } 
   
}
