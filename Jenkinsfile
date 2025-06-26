pipeline {
  agent any

  environment {
    ANSIBLE_HOST_KEY_CHECKING = 'False'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/Shirisha95-palla/terraform2.git'
      }
    }

    stage('Terraform Init and Apply') {
      steps {
        sh '''
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Run Ansible') {
      steps {
        sh '''
          ansible-playbook -i hosts playbook.yml
        '''
      }
    }
  }

  post {
    success {
      echo '✅ Deployment completed successfully!'
    }
    failure {
      echo '❌ Pipeline failed!'
    }
  }
}
