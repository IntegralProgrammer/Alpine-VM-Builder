FROM alpine:3.9

RUN apk update
RUN apk add \
	linux-vanilla \
	openrc \
	bash

RUN sh -c "echo e1000 >> /etc/modules"
RUN sh -c "echo -ne '/dev/sda\t/\text4\terrors=remount-ro,rw 0 0\n' > /etc/fstab"

RUN rc-update add modules
RUN rc-update add localmount

#Install any needed Alpine packages here, for example:
#RUN apk add \
#	nano \
#	python


#Setup the Entrypoint
ADD entrypoint.sh /bin
RUN chmod +x /bin/entrypoint.sh
RUN bash -c "cat /etc/inittab | sed -e s/'tty1::respawn:\/sbin\/getty 38400 tty1'/'tty1::respawn:\/bin\/entrypoint.sh'/g > /inittab"
RUN mv /inittab /etc/inittab


#This entrypoint is ignored in the VM image version. Modify entrypoint.sh instead.
CMD bash
