#kubectl -n kubernetes-dashboard create token admin-user
ns="kubernetes-dashboard"
user="admin-user"
kubectl -n $ns describe secret $(kubectl -n $ns get secret | grep $user | awk '{print $1}')
