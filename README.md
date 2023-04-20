PREQs:
- Assuming there's a DB configured in place
- Assuming there's a vault instance to work with for secrets

Create AWS Security Group for Load Balancer
- code in `sg_elb.tf`

Create AWS Load Balancer
- code in `elb.tf`
- The newly created application load balancer will require at least 2 subnets so, I am attaching both the subnets
- I have enabled cross-zone load balancing
- I have defined the health check policy so that I will always have healthy instances associated with my load balancer

Create AWS Launch configuration
- code in `launch_config.tf`
- Here I am using AWS Linux 2 as the AMI instance and using user data for configuring the newly created instances. I will discuss the user data part later in the article.
- Key pair has already existed in the region
- I am using create_before_destroy here to create new instances from a new launch configuration before destroying the old ones.

Create AWS Security group for EC2 instances
- code in `sg_ec2.tf`
- Here I am creating inbound rules for ports 22,80 & 443 and opening outbound connection for all the ports for all the IPs.

Create AWS Auto Scaling Group
- code in file `asg.tg`
- There will be a minimum of 1 instance to serve the traffic.
- There will be at max 2 instancess to serve the traffic.
- Auto Scaling Group will be launched with 1instance
- Auto Scaling Group will get information about instance availability from the ELB
- I have set up a collection for some Cloud Watch metrics to monitor the Auto Scaling Group state.
- Each instance launched from this Auto Scaling Group will have Name a tag set to web.

Create AWS Auto Scaling Policy
- code in `asg_policy.tf`
- aws_autoscaling_policy declares how AWS should change Auto Scaling Group instances count in when aws_cloudwatch_metric_alarm trigger.
- cooldown option will wait for 300 seconds before increasing Auto Scaling Group again.
- aws_cloudwatch_metric_alarm is an alarm, which will be fired, if the total CPU utilization of all instances in our Auto Scaling Group will be the greater or equal threshold value which is 70% during 120 seconds.
- aws_cloudwatch_metric_alarm is an alarm, which also will be fired, if the total CPU utilization of all instances in our Auto Scaling Group will be the lesser or equal threshold value which is 30% during 120 seconds.

Create a user data file
- commands are in `data.sh`
- Here I am installing docker and running SOME_CINT_REPO website’s docker image.
- install mysql client on the instance and login as admin. 


Additional notes:

- How would a future application obtain the load balancer's DNS name if it wanted to use this service?
from aws's documentation: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html

  - Using the ELB I've added to code
  - A registered domain name. You can use Route 53 as your domain registrar, or you can use a different registrar.
  - Route 53 as the DNS service for the domain. If you register your domain name by using Route 53, we automatically configure Route 53 as the DNS service for the domain.
  - Configure Amazon Route 53 to route traffic to an ELB load balancer.

- What aspects need to be considered to make code work in CI/CD pipeline (How does is successfully and safely get into production)?
  - Pipeline will perform login to vault, and then fetch the proper env vars for PROD and store them as env vars. data.sh will in turn login to DB with proper cerdentials required.
