
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

5. **Build the Pipeline**