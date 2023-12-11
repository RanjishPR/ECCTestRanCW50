#!/usr/bin/env groovy
@Library(['piper-lib', 'piper-lib-os']) _

node('master') {
	dockerExecuteOnKubernetes(script: this, dockerEnvVars: ['pusername':pusername, 'puserpwd':puserpwd], dockerImage: 'refapps.int.repositories.cloud.sap/sfext:v3' ) {

      try {	
	
		stage ('Build') { 
			deleteDir()
      			checkout scm	 
	 		sh '''
			    npm config set unsafe-perm true
			    npm rm -g @sap/cds
			    npm i -g @sap/cds-dk	
			'''
			packageJson = readJSON file: 'package.json'
			packageJson.cds.requires.API_BUSINESS_PARTNER["[production]"].credentials.destination = "bupa-ecc-mock"
			writeJSON file: 'package.json', json: packageJson
			sh '''
			   cat package.json
			   mv ./build/xs-security.json xs-security.json
			   mbt build -p=cf
			'''  
		 
	  	}

	  	stage('Deploy Mock'){
			setupCommonPipelineEnvironment script:this
			cloudFoundryDeploy script:this, deployTool:'mtaDeployPlugin'
                	sh'''
                    	   git clone https://github.com/SAP-samples/cloud-extension-ecc-business-process.git --branch 'mock'                         			
			   mv ./build/mta1.yaml cloud-extension-ecc-business-process/mta.yaml
			   cd cloud-extension-ecc-business-process
			   mbt build -p=cf
			'''
			cloudFoundryDeploy script:this, deployTool:'mtaDeployPlugin', mtaPath: 'cloud-extension-ecc-business-process/mta_archives/Mockserver_1.0.0.mtar'
	
       	        }

		stage('Mock Integration Test'){		
			withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'pusercf2', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
				sh "cf login -a ${commonPipelineEnvironment.configuration.steps.cloudFoundryDeploy.cloudFoundry.apiEndpoint} -u $USERNAME -p $PASSWORD -o ${commonPipelineEnvironment.configuration.steps.cloudFoundryDeploy.cloudFoundry.org} -s ${commonPipelineEnvironment.configuration.steps.cloudFoundryDeploy.cloudFoundry.space}"
			}
			sh '''
				appId=`cf app BusinessPartnerValidation-srv --guid`
				`cf curl /v2/apps/$appId/env > tests/testscripts/util/appEnv.json`
				npm install --only=dev
				npm run-script test:rest-api
			'''
			
	    }
	  
	  	stage('Redeploy'){
		   	sh "rm -rf *"
      			checkout scm
		   	sh '''
			    mv ./build/xs-security.json xs-security.json
			    mbt build -p=cf
			'''
			cloudFoundryDeploy script:this, deployTool:'mtaDeployPlugin'  
	   	 } 
		
		
		stage('UI Test'){
		   
			build job: 'ECCExtensionDemoscript'
		
		}
		
		stage('Undeploy'){
			sh'''
				echo 'y' | cf undeploy Mockserver
		   		echo 'y' | cf undeploy BusinessPartnerValidation
		   	'''	 
	    	}
	      
      }
	catch(e){
		echo 'This will run only if failed'
		currentBuild.result = "FAILURE"
	}
	finally {
		 emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: 'DL_5731D8E45F99B75FC100004A@global.corp.sap,DL_58CB9B1A5F99B78BCC00001A@global.corp.sap'
	}
		
    }	
} 
