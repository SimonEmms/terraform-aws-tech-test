# Notes

## Initial Project Config
- Add `.gitignore` file
- Initialise Terraform workspace
- Add tags for Name, Owner and Project to each resource that supports them. I've used a map-type variable to contain the basic, repeated tags in a reusable manner.

## Exercise 1
- Best practice for resilience in a single region from these docs:
  - https://d1.awsstatic.com/whitepapers/compliance/AWS_Operational_Resilience.pdf
  - https://www.artifakt.io/blog/2018/01/news/cto-advice-scalability-resilience-with-aws-7599
  indicates creating an Elastic Load Balancer that directs traffic to instances in each of the availability zones in a given region.
- Taking this example from the Terraform documentation: https://www.terraform.io/docs/providers/aws/r/elb.html I've edited it for the requirements of the exercise.