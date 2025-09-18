Here’s a visual to make it clear:

* The **Security Group** sits outside the instance, wrapped around the **ENI (network card)**.
* It filters inbound/outbound traffic at the **hypervisor layer**, before the OS ever sees a packet.
* The **EC2 instance** only receives what passes through the Security Group; anything blocked never reaches the VM.

This is why Security Groups are different from OS firewalls: they’re transparent to the VM, enforced externally, and always applied even if the OS firewall is disabled.

Want me to also make a **side-by-side diagram of Security Groups vs. NACLs**, so you can see how they compare (ENI vs. subnet layer)?
