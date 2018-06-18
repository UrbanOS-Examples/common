## What kubeconfig.Jenkinsfile is doing

### It's using scp to copy the kubeconfig file from $HOME/kubeconfig from the provided kubernetes master IP to /root/.kube/config on the Jenkins server. It takes the ip address of the kube master as a parameter. This is intended to be a downstream job from Kubernetes deployment so Jenkins is authenticated to the thing it creates.
