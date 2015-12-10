FROM alpine:3.1
ENV WEMUX_VERSION v3.2.0
ENV WEMUX_URL https://raw.githubusercontent.com/zolrath/wemux/${WEMUX_VERSION}/wemux 
ADD ${WEMUX_URL} /usr/local/bin/wemux
RUN chmod 775 /usr/local/bin/wemux
RUN apk add --update bash tmux openssh && \
    ssh-keygen -A && \
    rm -rf /var/cache/apk/*
    
ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D"]
