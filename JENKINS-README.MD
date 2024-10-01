
# Jenkins Pipeline Build

Follow the steps to build the pipeline.

**Note**: stages of the pipeline itself in the [Jenkins-file](Jenkinsfile) inside the project

1. **Install Required Jenkins Plugins**
* First, ensure the following plugins are installed in Jenkins:

      Git Plugin: To pull code from GitHub.
      Docker Pipeline Plugin: To interact with Docker within Jenkins pipelines.


* To install the plugins:

        Go to Jenkins dashboard.
        Navigate to Manage Jenkins > Manage Plugins.
        Search for the plugins above and install them.




2. **Create a New Pipeline Job in Jenkins**

* In Jenkins, go to the dashboard and click New Item.
* Enter a name for the job (e.g., TodoList-Docker-Pipeline).
* Select Pipeline as the project type and click OK.
3. **Configure the Pipeline**

* In the pipeline configuration, under the Pipeline section, select Pipeline script from SCM.
* Choose Git as the SCM.
* Enter your GitHub repository URL in the Repository URL field.
* Set the Branch to main
* In the Script Path field, enter Jenkinsfile



3. **Save the configuration**

4. **Add Credentials (for Docker Hub)**

* If you're pushing the Docker image to Docker Hub, go to Manage Jenkins > Manage Credentials.
* Add Username with password credentials and give it an ID (docker-hub-credentials-id), which you reference in the Jenkinsfile under DOCKER_HUB_CREDENTIALS.

5. **Sonarqube token:**
- Go to public_ip:9000/account/security.
- Change public_ip with the public IP of the instance.
- Next, click on Generate new token [ save the token with name as jenkins for easy reference] -> Copy the token and save it somewhere.
- in Jenkins, add new credentials with id "sonarqube-cred" as "secret text"

6. **Configure Maven in Jenkins**
- Navigate to Jenkins > Manage Jenkins > Global Tool Configuration.
  Scroll to the Maven Section:

- If Maven is not listed, click Add Maven.
- Enter a name for your Maven installation (e.g., Maven 3.8.6).
- Optionally, select Install Automatically if you want Jenkins to install it on agents when needed. Otherwise, specify the installation path.
  Save the Configuration.

7.**Configure Email Settings**

- Click on “Manage Jenkins” and then “Configure System”.
- Scroll down to the “Extended E-mail Notification” section and click on “Advanced”.
- Enter the SMTP server address for your email provider in the “SMTP server” field.
- in case of gmail : "smtp.gmail.com"
- Enter the port number for your SMTP server in the “SMTP port” field.
- port for Gmail SMTP : 587
- Choose the appropriate encryption method for your email provider in the “Use SSL” or “Use TLS” field.
- you need to create App password in Gmail

8.**Configure Sonar With Jenkins**

- Click on “Manage Jenkins” and then “Plugins”.
- Install 
  * “Sonar Quality Gates Plugin“
  * “SonarQube Scanner for Jenkins“ 


9.**Add Jenkins web hook in Sonar**

- Go to the project Click on “Project Settings” and then “Webhooks”.
- Click on “Create“ then set name and  URl set to ”http://ec2-15-236-175-182.eu-west-3.compute.amazonaws.com:8080/sonarqube-webhook/”

10.**Build the Pipeline**
