#!groovy

pipeline {
  agent any
  environment {
    GOPROXY = 'https://goproxy.cn,direct'
    successwxmsg = sh(returnStdout: true, script: 'cat $JENKINS_HOME/wechat-templates/success_wechat_tmp.md | sed "s/JOB_NAME/$JOB_NAME/"')
  }
  tools {
    go 'go'
  }
  stages {
    stage('Clone') {
      steps {
        git(url: 'https://github.com/hong-t/cicd-demo', branch: '$BRANCH_NAME', changelog: true, credentialsId: 'KK-github-key', poll: true)
      }
    }

    stage('Prepare') {
      steps {
        sh 'apt-get update -y; apt-get install gcc -y'
        // Get linter and other build tools.
        sh 'go get -u golang.org/x/lint/golint'
        sh 'go get github.com/tebeka/go2xunit'
        sh 'go get github.com/t-yuki/gocover-cobertura'

        // Get dependencies
        sh 'go get golang.org/x/image/tiff/lzw'
        sh 'go get github.com/boombuler/barcode'
      }
    }

    stage('Check Format') {
      steps {
        sh 'test -z $(gofmt -l .)'
      }
    }

    stage('Linting') {
      steps {
        sh '(go vet ./... >govet.txt 2>&1) || true'
        sh '(golint ./... >golint.txt 2>&1) || true'
      }
    }

    stage('Compile') {
      steps {
        sh 'make verify-build'
      }
    }

    stage('Unit Tests') {
      steps {
        // sh 'go test'
        sh 'echo Fake go testing'
      }
    }

    stage('Test coverage') {
      steps {
        // sh 'go test -coverprofile=coverage.out ./...'
        // sh '${env.HOME}/go/bin/gocover-cobertura < coverage.out > coverage.xml'
        // step([$class: 'CoberturaPublisher', coberturaReportFile: 'coverage.xml'])
        sh 'echo Fake go test coverage'
      }
    }

    stage('Post') {
      steps {
        // Assemble vet and lint info.
        // warnings parserConfigurations: [
        //   [pattern: 'govet.txt', parserName: 'Go Vet'],
        //   [pattern: 'golint.txt', parserName: 'Go Lint']
        // ]

        // sh 'go2xunit -fail -input gotest.txt -output gotest.xml'
        // junit "gotest.xml"
        sh 'echo Posting'
      }
    }
    stage('Release') {
      steps {
        sh 'echo Releasing'
      }
    }
  }
  post('Report') {
    success {
      script {
        wechat corpid: 'ww0bdc8677284e622b',
        secret: '72khfzQ6fKnftu97cflkVof-5s15VfKbku67napI02E',
        agentid: '1000004',
        toparty: '2',
        touser: 'ALL',
        totag: '1',
        markdown: env.JOB_NAME + env.successwxmsg
     }
     }
    always {
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/success_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
    failure {
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/fail_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
  }
}
