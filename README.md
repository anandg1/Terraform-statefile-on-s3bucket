# Storing Terraform remote states in AWS S3 Bucket

Let me demonstrate a simple way to use S3 backend to store your terraform states remotely.

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)]()

# Description:

When a terraform stack is deployed, terraform creates a state file. The state file keeps track of what resources have been deployed, all parameters, IDs, dependencies, failures and outputs defined in your stack.
The state file (JSON) would be committed to the repository containing your terraform stack code.
This created a few problems:
- Concurrency: If 2 or more developers are working in the stack, they won’t see the other state until it’s pushed to the repository.
- Automated Deployment: A CI tool that deploys the stack automatically would need to commit the new state file to the repository
- Easily corruptible: In case of a merge conflict or human error, the state file can be corrupted or gone. If this happens, the stack becomes unmaintainable, resources need to be manually/individually imported or cleaned and then re-created with terraform

Inorder to solve all these problems, we are going to use an AWS S3 bucket to store the states remotely.

# Pre-requisites:

1) An AWS s3 bucket
2) An IAM user with privilege to access s3 bucket.

> If you are using an existing IAM user who doesn't have the privilege, please attach the following policy to get access to s3.
```sh
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}
```


## Procedure:

I have already created an s3 bucket storage named 'tf.state-bucket' with 'bucket versioning' enabled.

![alt text](https://github.com/anandg1/Terraform-statefile-on-s3bucket/blob/main/01.jpg)

Now, add the following code in your main.tf (or any other) terraform file in the working directory.

```sh
terraform {
        backend "s3"{
        bucket      = "tf.state-bucket"
        key         = "terraform.tfstate"
        region      = "ap-south-1"
        encrypt     = false
        }
}
```
> Here, key is the /path/to/the/state/file/terraform.tfstate in s3 bucket

Now, the configurations need reinitialization as we have made a change. So we have to run : 
```sh
terraform init
```
with either the "-reconfigure" or "-migrate-state" flags to use the newly changed configuration.

Output:

```sh
root@AG:~/terraform# terraform init -reconfigure

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.56.0

Terraform has been successfully initialized!
```
Now, inorder to validate the terraform files, run the following command:
```sh
terraform validate
```
Now, inorder to create and verify the execution plan, run the following command:
```sh
terraform plan
```
Now, let us executes the actions proposed in a Terraform plan by using the following command:
```sh
terraform apply
```
Upon checking our s3 bucket again, we could see that the tfstate file has appeared in it.

![alt text](https://github.com/anandg1/Terraform-statefile-on-s3bucket/blob/main/02.jpg)

Upon checking our local end, we could verify that the tfstate file existing in local hand has become empty.
```sh
root@AG:~/terraform# ls -l | grep terraform.tfstate
-rw-r--r-- 1 root root    0 Sep  2 23:08 terraform.tfstate
```

## Conclusion:

The terraform writes the details of its states directly to a remote data store with versioning enabled, thereby makes it easier to manage as well as more secure.
