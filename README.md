# SOCKS5 Reverse Proxy

Forward requests to remote server over SOCKS5

The primary use of this proxy is to reach a remote device running on a Tailscale Tailnet from an AWS EKS cluster. Current constraints due to the EKS CNI prevent a Tailscale subnet-router running in EKS from completing NAT traversal. To work around this constraint the container running the Tailscale processes must run in [userspace][tailscale_userspace].

When running in userspace Tailscale can only act as a proxy. Since certain applications don't natively support proxying requests over SOCKS5 this proxy allows those apps to send their requests to the remote API without having to change the codebase.

_work in progress_

[tailscale_userspace]: https://tailscale.com/kb/1112/userspace-networking