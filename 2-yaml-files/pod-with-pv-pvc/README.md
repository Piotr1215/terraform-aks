# Persistent volume mounted to pod

- pv of type "hostPath" mounted to a node where pod is scheduled (mount location /kube)
- pvc in pod taking 100Mi out of 250Mi provisioned by pv
- try to create a file by ssh into node where pod is scheduled
- `sudo cat > file.txt`
- delete pod and recreate it
- is the file still there?
