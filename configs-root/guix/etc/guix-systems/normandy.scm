  (add-to-load-path "/etc/guix-modules")

(use-modules (gnu)
	         (gnu services)
	         (gnu services dbus)
	         (aprilsnow services throttled)
	         (gnu services pm)
	         (gnu packages gnome)
	         (gnu packages firmware)
	         (gnu packages)
	         (nongnu packages linux)
	         (nongnu system linux-initrd)
	         (gnu services virtualization)
	         (gnu services shepherd)
	         (gnu services avahi)
	         (gnu services admin)
	         (gnu system nss)
	         (guix channels)
	         (gnu services mcron)
	         (gnu services docker)
	         (gnu packages wm)
	         (aprilsnow services mount-rshared)
	         (aprilsnow services virsh)
	         (aprilsnow packages gnome)
	         (gnu services linux)
	         (gnu packages gnome)
	         (gnu packages fonts)
	         (gnu packages networking)
	         (guix gexp)
	         (guix packages)
	         (srfi srfi-1)
	         (ice-9 match))
(use-service-modules linux desktop networking ssh xorg)
(use-package-modules linux package-management)

  (define (extract-propagated-inputs package)
    ;; Drop input labels.  Attempt to support outputs.
    (map
     (match-lambda
       ((_ (? package? pkg)) pkg)
       ((_ (? package? pkg) output) (list pkg output)))
     (package-propagated-inputs package)))

  (define %my-services
    (modify-services %desktop-services
      (guix-service-type config => (guix-configuration
				    (inherit config)
				    (substitute-urls
				     (append (list "https://substitutes.nonguix.org")
					     %default-substitute-urls))
				    (authorized-keys
				     (append (list (local-file "./signing-key.pub"))
					     %default-authorized-guix-keys))))
      (gdm-service-type config => 
      		     (gdm-configuration
      		      (inherit config)
      		      (wayland? #f)
      		      (default-user "aprilsnow")
       		      (auto-login? #t)))
      (dbus-root-service-type config =>
			      (dbus-configuration (inherit config)
						  (services (list libratbag blueman fwupd))))))

  (define my-username "aprilsnow")

(operating-system

 (locale "en_US.utf8")
 (timezone "Europe/Kyiv")
 (keyboard-layout
  (keyboard-layout
   "us,ua"                  ; US + Ukrainian
   "dvorak,"                ; Dvorak for US, default for UA
   #:options '("grp:win_space_toggle" "caps:swapcaps")))

 (host-name "normandy")

  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  (groups 
   (cons* 
    (user-group (name "games")) ;; For libratbagd
    (user-group (name "realtime"))
    %base-groups))

  (users (cons* (user-account
		 (name my-username)
		 (comment "四月雪")
		 (group "users")
		 (home-directory "/home/aprilsnow")
		 (supplementary-groups
		  '("wheel" "netdev" "audio" "video" "lp" "libvirt" "kvm" "games" "docker" "realtime")))
		%base-user-accounts))

  (packages
   (append
    (map specification->package
	 (list
	  "bluez"
	  "openssh"
	  "blueman"
	  "i915-firmware"
	  "vim"
	  "mesa"
	  "glu"
	  "xdg-desktop-portal-gtk"
	  "i3lock"
	  "libratbag"
	  "git"))
    %base-packages))

  (name-service-switch %mdns-host-lookup-nss)

  (services
   (append
    (list
     ;; (service gnome-desktop-service-type
     ;; 	    (gnome-desktop-configuration
     ;; 	     (shell (extract-propagated-inputs gnome-meta-core-shell-patched))))
     ;; Enable triple buffering support
     ;; I'm sure there's a more proper way to approach this, but this works for now
     (service xfce-desktop-service-type)

     (service openssh-service-type)

     ;; Not necessary for Gnome
     (service screen-locker-service-type
	      (screen-locker-configuration
	       (name "i3lock")
	       (program (file-append i3lock "/bin/i3lock"))))

     (service tlp-service-type
	      (tlp-configuration
	       (tlp-enable? #t)
	       (cpu-scaling-governor-on-ac (list "performance"))
	       (cpu-scaling-governor-on-bat (list "powersave"))
	       (energy-perf-policy-on-ac "")
	       (cpu-boost-on-ac? #t)
	       (cpu-boost-on-bat? #f)
	       (start-charge-thresh-bat0 70)
	       (stop-charge-thresh-bat0 75)
	       (start-charge-thresh-bat1 70)
	       (stop-charge-thresh-bat1 75)))

     (service bluetooth-service-type
	      (bluetooth-configuration
	       (auto-enable? #f)))

  (service throttled-service-type)

  (service kernel-module-loader-service-type
	   '("msr")) ;; required for throttled

  mount-rshared-service

  (extra-special-file "/etc/subuid"
		      (plain-file "subuid" (string-append my-username ":100000:65536")))

  (extra-special-file "/etc/subgid"
		      (plain-file "subgid" (string-append my-username ":100000:65536")))

  virsh-net-default-service

  (service pam-limits-service-type
	   (list (pam-limits-entry "*" 'hard 'nofile 524288)
		 (pam-limits-entry "@realtime" 'both 'rtprio 99)
		 (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)))

  (service nftables-service-type)

  (extra-special-file "/lib64/ld-linux-x86-64.so.2"
		      (file-append glibc "/lib/ld-linux-x86-64.so.2"))

  (set-xorg-configuration
   (xorg-configuration
    (keyboard-layout keyboard-layout)))

  (service virtlog-service-type
	   (virtlog-configuration
	    (max-clients 1000)))

  (service libvirt-service-type
	   (libvirt-configuration
	    (unix-sock-group "libvirt")
	    (tls-port "16555")))
  (service containerd-service-type)
  (service docker-service-type)

  (service zram-device-service-type
	   (zram-device-configuration
	    (size "8172M")
	    (compression-algorithm 'zstd))))
  %my-services))

(bootloader (bootloader-configuration
	         (bootloader grub-efi-bootloader)
	         (targets (list "/boot/efi"))
	         (keyboard-layout keyboard-layout)))
(mapped-devices 
 (list
  ;; Root disk (LUKS)
  (mapped-device
   (source (uuid "89fa4ff1-c1b6-43f8-b896-062c71db544f"))
   (target "cryptdata")
   (type luks-device-mapping))

  ;; Swap device (optional)
  (mapped-device
   (source (uuid "0da908ca-849a-40e4-a052-a9eceda16148"))
   (target "cryptswap")
   (type luks-device-mapping))))


(file-systems (cons* (file-system
			          (mount-point "/boot/efi")
			          (device (uuid "5696-CD14"
				                    'fat32))
			          (type "vfat"))

                     ;; Root Filesystem inside LVM
                     (file-system
                      (mount-point "/")
                      (device "/dev/mapper/data-root")
                      (type "ext4")
                      (dependencies (list "cryptdata")))

                     %base-file-systems))
(swap-devices
 (list
  (swap-space
   (target "/dev/mapper/cryptswap")))))
