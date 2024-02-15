FROM --platform=linux/amd64 python:3.9-slim

# Set working directory
WORKDIR /app

# Copy only necessary files
COPY flask-health-api.py requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port
EXPOSE 8082

# Command to run the application
CMD ["python", "flask-health-api.py"]

