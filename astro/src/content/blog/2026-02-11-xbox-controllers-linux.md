---
title: Xbox Controllers on Linux and how to set them up
date: 2026-02-11
tags: [gaming, linux, btwirunarch]
---

Xbox controllers have been my favorite since the 360 and I prefer their ergonomics to everything else I have tried. Sadly, they're pretty finicky when it comes to making them work under Linux. Expected considering Xbox is a brand of Microsoft, but I wish that wasn't the case. Regardless, it is still doable, if requires some elbow grease.

## Controllers and their revisions

I would like to first point out that if you have a controller that has an Xbox controls layout but is not made by Microsoft, this article may be of little help.

Usually these controllers, especially if they're made by 8bitdo or GameSir, come with non-bluetooth dongles or have DualShock 4 emulation mode. Both of these options should work out of box on Linux. If you find an interesting quirk with a rare controller, feel free to get in touch and I'll consider updating this post with a controllers table or maybe creating a dedicated page on this website - you never know.

### Original Xbox and 360 controllers

If you have an [original Xbox controller](https://en.wikipedia.org/wiki/Xbox_controller), with an adapter or re-soldered USB plug, or a [360 controller](https://en.wikipedia.org/wiki/Xbox_360_controller), wired or wireless with an [official receiver](https://en.wikipedia.org/wiki/List_of_Xbox_360_accessories#Wireless_Gaming_Receiver), they are supported by [xpad](https://github.com/paroj/xpad) module and should work out of box on any modern linux kernel.

### Xbox One controllers

[Xbox Wireless Controllers](https://en.wikipedia.org/wiki/Xbox_Wireless_Controller) starting from Xbox One are where things start to get a bit weird. The original models (1537, 1697, and 1698) only support Microsoft's proprietary wireless dongle. If you're only planning to use them in wired fashion, aforementioned `xpad` kernel module works okay with them. If, however, you're planning to use one of these wirelessly with an [Xbox Wireless Adapter](https://en.wikipedia.org/wiki/Xbox_Wireless_Controller#Xbox_Wireless_Adapter_for_Windows), you are going to have to rely on a newer [xone](https://github.com/dlundqvist/xone) kernel module that is not shipped in Linux kernel and dongle firmware that has to be extracted from Windows drivers.

If you're running Arch, getting it to work is as easy as installing a headers package for your kernel, then installing [xone-dkms](https://aur.archlinux.org/packages/xone-dkms) and [xone-dongle-firmware](xone-dongle-firmware) from AUR. I do not own an older (model 1713) dongle so cannot test it but the newer one (model 1790) does not work without firmware.

`xone` kernel module also has a potential disadvantage of conflicting with the older `xpad` module. That means that you will have to blacklist the `xpad` module if you want to use the `xone` one (AUR package does that for you automatically). If you don't want to lose compatibility with all the other controllers supported by `xpad`, you're going to need to additionally install an [xpad-noone](https://github.com/forkymcforkface/xpad-noone) module. I'm not providing an AUR link here because the version currently used in AUR is grossly outdated and does not work properly on 6.1x kernels which are, at the time of publication, mainline kernels for Arch.

Second revision of Xbox One controllers (models 1708 and 1797) got bluetooth support so you no longer need to pay Microsoft for extra hardware. This generation is my favorite because you can still get them on the cheap second-hand and because the only benefit of a newer model (1914) is having a dedicated screenshot button that currently has limited support on Linux. To run these wired or wirelessly through a dongle, you are going to need to follow the same steps as for the previous controller revision (models 1537, 1697, and 1698). If you want to connect them via Bluetooth, however, it's going to get a bit more complicated.

Out-of-box (on firmware versions prior to 5.0) they only support older versions of Bluetooth protocols that work reliably on Windows but are known to cause pairing fails and constant connection loops on Linux, making them practically unusable. However, somewhere in 2021 Microsoft has released a [firmware update](https://news.xbox.com/en-us/2021/09/08/xbox-controller-firmware-update-rolling-out-to-insiders-starting-today/) for them which added BLE ([HOGP](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy#HID_connectivity), to be specific) support to Bluetooth-capable controllers. Connection via newer BLE stack using `xpadneo` is much more stable and I would thus strongly recommend for you to update your Xbox One controller to the latest firmware version on Windows or an Xbox console and follow the setup for Xbox Series controllers outlined in the next section.

It is important to note that connecting via BLE stack would also require for your computer's Bluetooth adapter to also support it. All bluetooth chipsets that are certified for Bluetooth 5.0 and higher are required to support BLE[^1], but it is better to check your specific model and buy a different one if necessary. It would be a much cheaper alternative to buying Microsoft's proprietary adapter.

There is another potential caveat to updating your controller: in my particular case updating a model 1708 controller resulted in legacy bluetooth stack being disabled on it. Since downgrading firmware on these controllers is practically impossible, beware that it may be a one-way operation. This is, sadly, statistically insignificant as I have tested a single controller but since it happened to me, it may happen to someone else too so better be safe than sorry.

### Xbox Series controllers

Xbox Series Wireless Controllers (model 1914) don't have any protocol differences among themselves, unlike their older counterparts. However, unlike the Xbox One controllers, they aren't properly supported by the bundled `xpad` module at all. If you're planning on using them in wired or wireless fashion using Xbox Wireless Adapter, you're going to need to rely on `xone` kernel module. Its installation and quirks have been covered in the [Xbox One controllers](#xbox-one-controllers) section so you can refer to it if you're planning to connect them using either of these two options. It is important to note that `xone` kernel module does not support the share button on these controllers and if you want to be able to use it, your only option would be to connect the controller wirelessly over Bluetooth.

If you'd like to connect Xbox Series controllers via Bluetooth, you're going to need an [xpadneo](https://github.com/atar-axis/xpadneo) kernel module and jump through some hoops. First connection is [notorious for being problematic](https://github.com/atar-axis/xpadneo/issues/295) if you haven't connected the gamepad to Windows using the very same bluetooth adapter (controller on the WiFi card or a USB dongle) you're using under Linux. I, personally, did not encounter any of these problems but since I have migrated my WiFi+BT card from my laptop to my desktop, there is a chance I had paired my controllers to that very laptop in the past. Just in case this is still a real problem, I would recommend pairing the gamepad to the same Bluetooth adapter you're planning to use with Linux, ideally on the same hardware.

If you are _not_ dual-booting Windows and Linux and have no plans to do so in the foreseeable future, you can install an evaluation copy of Windows in a virtual machine, USB-passthrough your Bluetooth adapter into it and pair your gamepad to this virtualized Windows install. After that, pairing to Linux should be painless, assuming you have `xpadneo` kernel module installed and loaded.

If you are dual-booting Windows and Linux, just pair the controller to Windows first, then reboot into Linux and pair it again. Additionally, if you do not want to re-pair your controller on every OS swap, you can follow these steps to copy authorization keys from Linux into Windows:

1. On Windows, make sure the OS still considers your controller "paired". If this is not so, re-pair it under Windows, then reboot into Linux and re-pair it.
2. On Linux, open your preferred bluetooth control software and figure out MAC addresses for your Bluetooth adapter and your gamepad.
3. Open the `/var/lib/bluetooth/{{ BT adapter MAC address }}/{{ Xbox Controller MAC address }}/info` file as root and copy `IdentityResolvingKey` and either `PeripheralLongTermKey` or `SlaveLongTermKey`[^2] from it into a temporary text file *that you can also read from Windows*.
4. Reboot into Windows and open `regedit` as `SYSTEM` account using `PsExec64` from [PSTools](https://download.sysinternals.com/files/PSTools.zip): `.\PsExec64.exe -s -i regedit.exe`
5. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\{{ BT adapter MAC address }}\{{ Xbox Controller MAC address }}` path and replace `LTK` value with `PeripheralLongTermKey` or `SlaveLongTermKey` you have extracted in step (1).
6. If `IdentityResolvingKey` was present in step (1) and had a non-zero value, additionally replace the `IRK` value in Windows registry with it.
7. Reboot into Windows again to ensure the keys you have just migrated are used instead of the ones you have had before, and test that the controller works properly.
8. Optionally, reboot into Linux and test that key migration did not break anything.

At this point your Xbox controller should work perfectly well under Linux and, optionally, not require re-pairing when booting your computer into Windows. If you have encountered any difficulties that were not covered by this post, feel free to [reach out to me](/about/), especially if you have managed to overcome them and would like to share the solutions or fixes, and I'd gladly update this post.

[^1]: In Bluetooth 4.0 specification BLE implementation was optional and noticeable amount of Bluetooth chipsets that were based off of repurposed BR/EDR hardware do not support it. Starting with [Bluetooth Core specification 5.0](https://www.bluetooth.com/specifications/specs/core-specification-amended-5-0/), BLE became the base of the stack so a chipset cannot be certified as BT 5.x without implementing it. If you have a proper branded adapter like [TP-Link UB500](https://www.tp-link.com/us/home-networking/usb-adapter/ub500/) (not an ad, but I got recommended this specific adapter by a lot of IoT and open-hardware enthusiasts as an inexpensive reliable option) or if you're using a WiFi+Bluetooth card with known chipset, you should be good to go.

[^2]: In case of Xbox Wireless Controller, either only one of them is present or they are identical. Info came from the [key conversion table](https://wiki.archlinux.org/title/Bluetooth#Preparing_Bluetooth_5.1_Keys) in Dual-Boot section of [Bluetooth page](https://wiki.archlinux.org/title/Bluetooth) on ArchWiki.
