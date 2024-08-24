<powershell>

# Rename Machine
Rename-Computer -NewName "${windows_instance_name}" -Force;

# Setup proxy settings -- as needed

# Download/Install Chocolatey
cd C:\Windows\Temp;
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) -ErrorAction SilentlyContinue;

# Install packages (openjdk11, git, 7zip and nodejs) via choco and set JAVA_HOME
choco install -y openjdk11;
choco install -y git.install --params "'/GitAndUnixToolsOnPath /WindowsTerminal /NoAutoCrlf'";
choco install -y nodejs.install;
choco install -y 7zip.install;
[Environment]::SetEnvironmentVariable("JAVA_HOME", $env:JAVA_HOME + ";C:\Program Files\Eclipse Adoptium\jdk-11.0.24.8-hotspot\bin", "Machine");

# Create the Jenkins user directory and cd into it
New-Item -Path C:\Users\Jenkins -ItemType Directory -ErrorAction SilentlyContinue;
cd C:\Users\Jenkins;

# Download WinSW and rename as jenkinsagent.exe; download agent.jar from Jenkins Core, same name
curl.exe -Lo jenkinsagent.exe https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW-x64.exe;
curl.exe -Lo agent.jar ${jenkins_core_url}/jnlpJars/agent.jar;

# Create a jenkinsagent.xml Windows Service config file
$agentXmlContent = @"
<service>
  <id>jenkins</id>
  <name>Jenkins</name>
  <description>This service runs Jenkins continuous integration system.</description>
  <executable>C:\Program Files\Eclipse Adoptium\jdk-11.0.24.8-hotspot\bin\java.exe</executable>
  <arguments>-jar agent.jar -jnlpUrl ${jenkins_core_url}/computer/${jenkins_core_agent}/jenkins-agent.jnlp -secret ${jenkins_core_secret} -workDir "C:\Users\Jenkins"</arguments>
  <log mode="roll" />
  <onfailure action="restart" />
</service>
"@;
$agentXmlContent | Out-File -FilePath jenkinsagent.xml;

# Setup a service to run the agent on startup and restart on error
.\jenkinsagent.exe install;
.\jenkinsagent.exe start;

# Restart machine
shutdown -r -t 10; 

</powershell>
