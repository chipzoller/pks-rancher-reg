# pks-rancher-reg
Automatic registration of VMware Enterprise PKS Kubernetes clusters with Rancher Server.

## What Is This?

This is a shell script designed to be wrapped in a pod and deployed through Kubernetes which registers the cluster on which it runs with an external Rancher Server installation.

## How Does It Work?

By creating your own manifest (or using the sample provided in this repo) and putting it in a plan, you give Kubernetes the variables it needs in the form of secrets and the location of your image. When the "apply add-ons" phase of a PKS cluster build process begins, the Kubernetes resources are created and the image is pulled. The Pod runs the script inside a light-weight container, consumes the values as environment variables, and registers itself with Rancher.

One of the variables the script requires is the signing certificate for Rancher. This is to ensure the connection is made in a secure fashion and the API token is not revealed to a man-in-the-middle. The signing certificate MUST have line breaks after the header as well as after the certificate contents themselves. There should be NO line breaks mid-content. The entire thing should then be base64 encoded.

## Can I Use It Outside PKS?

Yes, the logic inside can be stripped out and used to register non-PKS clusters with Rancher Server. Some slight modifications will be required, specifically how to generate or provide the name used to register the cluster.
