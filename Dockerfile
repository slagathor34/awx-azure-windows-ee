ARG ANSIBLE_BUILDER_IMAGE=quay.io/centos/centos:stream9
FROM $ANSIBLE_BUILDER_IMAGE

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
USER root
RUN dnf -y update && \
    dnf -y install \
        python3 \
        python3-pip \
        git \
        python3-devel \
        gcc \
        openssl-devel \
        libffi-devel \
        rust \
        cargo \
        krb5-devel \
        krb5-libs \
        krb5-workstation \
        libxml2-devel \
        libxslt-devel \
        cyrus-sasl-devel \
        cyrus-sasl-gssapi && \
    dnf clean all

# Install Ansible and ansible-runner
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install ansible-core ansible-runner

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo && \
    dnf install -y azure-cli

# Create requirements file for Python dependencies
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip3 install -r /tmp/requirements.txt

# Create ansible user
RUN useradd -m ansible

# Switch to ansible user
USER ansible

# Install Ansible collections
RUN ansible-galaxy collection install azure.azcollection --force && \
    ansible-galaxy collection install ansible.posix --force && \
    ansible-galaxy collection install community.general --force && \
    ansible-galaxy collection install community.crypto --force && \
    ansible-galaxy collection install ansible.windows --force && \
    ansible-galaxy collection install community.windows --force

# Set working directory
WORKDIR /runner

# Default command
CMD ["/bin/bash"]
