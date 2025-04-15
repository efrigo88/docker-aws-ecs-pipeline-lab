FROM --platform=linux/amd64 python:3.9-slim

WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY src/ .
COPY data/ ./data/

# Run the application
CMD ["python", "main.py"]