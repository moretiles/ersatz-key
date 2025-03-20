# Ersatz-key

## Use a secondary drive to decrypt files on a Linux PC or server then seal it

---

## How it works

Writes [/etc/crypttab](https://www.man7.org/linux/man-pages/man5/crypttab.5.html) and [/etc/fstab](https://www.man7.org/linux/man-pages/man5/fstab.5.html) entries that use a key file on your machine to decrypt and mount an external LUKS encryped drive.
Creates a Systemd target called usb-unseal.target that triggers and causes the external drive to be unmounted and sealed.
You define what Systemd Units are part of usb-unseal.target to determine what is decrypted while the drive is unsealed, before the target activates.
A sample dependent service that uses [shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir's_secret_sharing) to use one key on the root drive and one key on the external drive to drive to produce a secret password is included.

## Considerations

* Any machine you plan to use this for is running Linux, this will not work on Windows or Mac. 
* Your Linux distribution uses or supports Systemd.
* You are comfortable storing the secret used to decrypt the USB or external hard drive. Highly recommended to encrypt.
* You are comfortable learning how Systemd Units work. You can use scripts and binaries in any lanaguage but will need to create and enable Systemd Units that activate and relate them.

## How to use

* You will need to partition the external drive, then use LUKS to set a keyfile, open the encrypted LUKS partition, and install a file system to it. Because there are many ways to do this you should find what is best for you and complete this step yourself. You will likely have to modify the base installation script if you do not plan to call the cryptroot mapper usb-luks or use an EXT4 filesystem.
* Run `ersatz-key_installer.sh` with the first argument being the path to the LUKS encrypted partition (for example /dev/sdc7) and the second argument being the path to the uncencrypted keyfile used to setup LUKS encryption for that drive. You will need to keep the unlock key in the same place. After running your computer should now decrypt, mount, reach the target, unmount, and seal the drive each boot.
* Create your own Systemd Units that set the attribute PartOf=usb-unseal.target or use the `keepass-ersatz-key_installer` with the pass to the shamir seal on your computer to try mine.

## What is Systemd, what are Systemd Units

Systemd is the init system used by the Debian, Red Hat, and Arch Linux families of Linux distributions. It starts with process id 1 and performs the initialization work to get the operating system running in userspace. Systemd Units allow developers and users to communicate to Systemd resources or services that it needs to be aware of.
Systemd is powerful and complex. If you are interested in learning about different kinds of Systemd Units I highly encourage you to look at the [man page](https://www.man7.org/linux/man-pages/man5/systemd.unit.5.html) for Systemd Units and related man pages for Systemd services, mounts, and other unit types.

Question: Why manage this using Systemd Units?
Answer: Uhh... it's complicated.
Systemd exists as an option or the only option for an init system across a massive portion of the widely used Linux variants. By managing configuration in terms of systemd units it means mounting and unmounting the external drive, encrypting and decrypting the external drive, scheduling your programs to run in parallel, and handling failures are the responability of one stable program that doesn't need to be installed and is designed to manage these kinds of webs of startup dependencies.
