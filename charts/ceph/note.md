ref: 
- https://github.com/ceph/ceph-container/tree/main/examples/kubernetes
- https://github.com/ceph/ceph-container/blob/main/examples/kubernetes/ceph-mon-v1-dp.yaml
- https://github.com/ceph/ceph-container/blob/main/examples/helm/ceph/templates/config/configmap.yaml
- https://github.com/ceph/ceph-container/blob/c5aaba5e3282b30e4782f2b5d6e4e362e22dfcb7/examples/coreos/units/ceph-mon%40.service

whole process:
### Generate ceph config by following [Generate keys and configuration](https://github.com/ceph/ceph-container/tree/main/examples/kubernetes#generate-keys-and-configuration)  
1. Install `jinja2` and `sigil` in linux
```shell
sudo dnf install python-jinja2 python3-jinja2-cli -y
# https://github.com/gliderlabs/sigil/releases/download/v0.11.0/sigil-linux-amd64
sudo curl -L --output /usr/local/bin/sigil https://github.com/gliderlabs/sigil/releases/download/v0.11.0/sigil-linux-amd64 \
&& sudo chmod +x /usr/local/bin/sigil
```
2. prepare the repo
```shell
git clone --depth=1 https://github.com/ceph/ceph-container.git
cd ./ceph-container/ceph-container/examples/kubernetes/generator
```
3. render the template
```shell
./generate_secrets.sh all `./generate_secrets.sh fsid`
```