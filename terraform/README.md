# DEPI-206-Terraform

In Amazon EKS, Elastic Load Balancers (ELBs) are typically created automatically when you expose your services using Kubernetes Service objects of type `LoadBalancer`. Here's a breakdown of when and how ELBs are created in an EKS environment:

### 1. **Service of Type LoadBalancer**
To create an ELB in EKS, you need to define a Kubernetes Service of type `LoadBalancer`. When this type of service is created, the following happens:

- Kubernetes interacts with the AWS API to provision an ELB automatically.
- The ELB is associated with the Service, and it directs traffic to the underlying pods.

### Example Service Manifest
Here's a simple example of a Kubernetes Service manifest that creates an ELB:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"  # Use "nlb" for Network Load Balancer, "elb" for Classic
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: my-app  # Ensure this matches the labels of your pods
```

### 2. **Ingress Resources**
If you are using an Ingress resource to manage access to your services, an ELB may also be created when you deploy an Ingress Controller, such as the AWS Load Balancer Controller. This controller manages the lifecycle of load balancers for your Ingress resources.

### Steps to Set Up ELB
1. **Deploy Your Application**: Make sure your application pods are running.
2. **Create a Service**: Define a Service of type `LoadBalancer` for your application.
3. **Check the ELB Status**: Once the Service is created, you can check the AWS Management Console under the EC2 Load Balancers section to see the created ELB.

### 3. **Considerations**
- **IAM Permissions**: Ensure that your EKS node IAM role has the necessary permissions to create and manage ELBs.
- **Subnets**: Make sure the subnets associated with your EKS cluster allow for the creation of ELBs, especially if you're using a VPC with specific configurations (like private subnets).
- **Ingress Controller**: If you prefer to manage your load balancing via Ingress, consider setting up an Ingress Controller, which will manage ELBs based on your Ingress rules.

### Summary
ELBs in EKS are created when you define a Service of type `LoadBalancer` or when you use an Ingress Controller that manages load balancers. If you’ve deployed a Service and don’t see an ELB, ensure that the Service type is set correctly, and check for any IAM or network-related issues that might prevent the ELB from being created. If you need assistance with a specific configuration or troubleshooting, let me know!
