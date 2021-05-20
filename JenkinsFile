pipeline {
    agent any

    stages {
        stage('GIT_Integration') {
            steps {
                git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/dearsundaram/AnsibleApache.git'
            }
        }
        stage('Execute Ansible Playbook') {
            steps {
                ansiblePlaybook credentialsId: 'ec2-user', disableHostKeyChecking: true, installation: 'Mac_ansible', inventory: 'inventory.txt', playbook: 'AnsibleApache.yml'
            }
        }
        
    }
}
