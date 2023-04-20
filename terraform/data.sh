sudo yum update -y
sudo yum install mysql -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo chmod 666 /var/run/docker.sock
docker pull <SOME_CINT_REPO>/<SOME_CINT_WEB>:v1
docker run -d -p 80:80 <SOME_CINT_REPO>/<SOME_CINT_WEB>:latest

mysql -h **some db-name** -P 3306 -u admin -p **use env vars, after some fancy vault auth made from the pipeline**