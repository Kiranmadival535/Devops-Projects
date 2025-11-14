# Use CentOS base image
FROM centos:7

# Maintainer info
LABEL maintainer="Supriya"

# Fix repo mirror issues
RUN cd /etc/yum.repos.d/ && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install required packages
RUN yum install -y httpd zip unzip curl && \
    yum clean all

# Set working directory
WORKDIR /var/www/html/

# Copy the downloaded zip file from your host into the container
COPY photogenic-master.zip .

# Unzip and move contents
RUN unzip photogenic-master.zip && \
    cp -rvf photogenic-master/* . && \
    rm -rf photogenic-master photogenic-master.zip

# Expose port 80 for HTTP
EXPOSE 80

# Start Apache in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
