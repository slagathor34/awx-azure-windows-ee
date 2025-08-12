#!/bin/bash

# Build script for AWX Azure Execution Environment
# This script builds the execution environment using ansible-builder

# Set variables
EE_NAME="awx-azure-ee"
EE_TAG="latest"

# Check if ansible-builder is installed
if ! command -v ansible-builder &> /dev/null; then
    echo "ansible-builder is not installed. Installing..."
    pip3 install ansible-builder
fi

# Build the execution environment
echo "Building execution environment: $EE_NAME:$EE_TAG"
ansible-builder build --tag $EE_NAME:$EE_TAG --verbosity 2 --extra-build-cli-args="--platform linux/amd64"

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built execution environment: $EE_NAME:$EE_TAG"
    echo "You can now push this image to your registry or use it locally in AWX"
    echo ""
    echo "To test the image:"
    echo "docker run -it --rm $EE_NAME:$EE_TAG /bin/bash"
    echo ""
    echo "To push to a registry:"
    echo "docker tag $EE_NAME:$EE_TAG your-registry/$EE_NAME:$EE_TAG"
    echo "docker push your-registry/$EE_NAME:$EE_TAG"
else
    echo "Build failed. Please check the output above for errors."
    exit 1
fi
