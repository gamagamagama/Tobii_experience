# Tobii_experience
Debug for tobii experience app that is unable to install from msstore bcs of error code 0x803fb005:
```bash
# The product couldn't be installed due to some missing dependencies.
# Make sure these drivers are installed:
# 'Tobii_AB-AwareUB40.inf','Tobii_AB-IS5Devkit940.inf','Tobii_AB-IS5Devkit850.inf'.

```
1. Run PowerShell or ISE as Administrator and run command that will allow you to run scripts :
```bash
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```
2. Run Tobii.ps1 script that register Tobii_experience app under current user
3. Logout & Log in 

PS: Anyway it solves only one of many problems that it can actually be, but mnimally can help you identify it and provide your own sollution. 
