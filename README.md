## Setup a RPM repository using nginx

- Add the rpms to the directory `rpm-packages`

- build the image with `docker build -t rpm-repo .`

- Run the container with `docker run -d -p 8080:80 rpm-repo`.

- Verify if the repository is acessible with `curl http://localhost:8080/repodata/repomd.xml`

Now, the RPM packages in /var/www/html/repo will be accessible through a web browser or with zypper tool.

### If you want to configure zypper to use it:

- Configure your clients to use the repository by creating a .repo file in /etc/zypp/repos.d/ directory. For example:

```
[my-repo]
name=my-repo
baseurl=http://<rpm-repo-ip-address>:8080/
enabled=1
gpgcheck=0

```

- Run `zypper refresh` and then `zypper install <package-name>` to install
  a package from the new repository

